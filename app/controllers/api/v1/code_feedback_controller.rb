module Api
  module V1
    class CodeFeedbackController < ApplicationController
      before_action :authenticate_with_api_key

      def create
        code = params[:code]
        return render json: { error: 'Code required' }, status: :bad_request unless code.present?

        begin
          feedback = run_code_feedback(code)
          render json: { data: { feedback: feedback } }, status: :ok
        rescue StandardError => e
          Rails.logger.error "Code Feedback Error: #{e.message}\n#{e.backtrace.join("\n")}"
          render json: { error: 'Failed to process code feedback' }, status: :internal_server_error
        end
      end

      private

      def authenticate_with_api_key
        key = request.headers['Authorization']&.split('Bearer ')&.last
        @api_key = ApiKey.find_by(key: key)
        if !@api_key || @api_key.status != 'active' || @api_key.expired?
          render json: { error: 'Invalid or expired API key' }, status: :unauthorized
        else
          @api_key.increment!(:usage_count)
          @api_key.update(last_used_at: Time.current)
        end
      end

      def run_code_feedback(code)
        require 'open3'
        safe_code = code.gsub("'", "\\'")
        script = <<~JS
          const esprima = require('esprima');
          try {
            const ast = esprima.parseScript('#{safe_code}', { loc: true });
            let feedback = 'Valid JavaScript';
            // Check for let vs const
            ast.body.forEach(node => {
              if (node.type === 'VariableDeclaration' && node.kind === 'let') {
                const isReassigned = node.declarations.some(dec => 
                  ast.body.some(n => 
                    n.type === 'ExpressionStatement' && 
                    n.expression.type === 'AssignmentExpression' && 
                    n.expression.left.name === dec.id.name
                  )
                );
                if (!isReassigned) {
                  feedback += '\\nConsider using "const" instead of "let" for variables that aren\\'t reassigned.';
                }
              }
            });
            return feedback;
          } catch (e) {
            return e.message;
          }
        JS
        stdout, stderr, status = Open3.capture3('node', '-e', script)
        Rails.logger.info "Node.js output: stdout=#{stdout}, stderr=#{stderr}, status=#{status}"
        status.success? && stderr.empty? ? stdout.strip : "Error: #{stderr.presence || 'Unknown error'}"
      end
    end
  end
end