module TemplateMailer
  module LoggingHelper
  	def log
  		if !@logger
  			@logger = Logger.new(STDOUT)
  			@logger.level = Logger::UNKNOWN
  		end
  		@logger
  	end
  end
end
