module Api
    module V1
      class CodeFeedbackController < ApplicationController
        before_action :authenticate_with_api_key
  
        def create
          code = params[:code]
          return render json: { error: 'Code required' }, status: :bad_request unless code.present?
  
          feedback = run_code_feedback(code)
          render json: { data: { feedback: feedback } }, status: :ok
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
          safe_code = code.gsub('"', '\\"') # Escape double quotes for JS string
          # Use console.log instead of return
          script = "const esprima = require('esprima'); try { esprima.parseScript(\"#{safe_code}\"); console.log('Valid JavaScript'); } catch (e) { console.log(e.message); }"
          stdout, stderr, status = Open3.capture3('node', '-e', script)
          stderr.empty? ? stdout.strip : "Error: #{stderr.strip}"
        end
      end
    end
  end