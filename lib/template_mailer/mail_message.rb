module TemplateMailer
  class MailMessage
  	# Constructor for the MailMessage class.
  	#
  	# ==== Parameters
  	# options::  An options Hash. The following keys are recognised within this
    #            Hash...
    #             * :html - The HTML content for the email message. Both this and
    #               text can be specified but at least one of them should be.
    #             * :text - The textual content for the email message. Both this
    #               and :html can be specified but at least one should be.
    #             * :server - When SMTP is the preferred email mecahnism (see the
    #               :via option) then this value should be a Hash of the parameters
    #               that will be used to talk to the SMTP server.
    #             * :via - The email mechanism to use to dispatch email messages.
    #               options are :sendmail (the default) or :smtp. If :smtp is
    #               specified then the :server option should also be given a
    #               value.
  	def initialize(options={})
  		@html   = options[:html]
  		@text   = options.fetch(:text, options[:txt])
      @server = options[:server]
      @via    = options.fetch(:via, :sendmail)
  	end
  	attr_reader :html, :text

    # This method attempts to send the contents of a mail message to a specified
    # set of recipients.
    #
    # ==== Parameters
    # options::  A Hash of the options to be used when sending the email.
    #            Recognised keys in this Hash are :subject (a String containing
    #            the email title), :recipients (either a String or Array list
    #            of email addresses that the message should be sent to) and
    #            :from (the email address that will be set as the message
    #            source).
  	def send(options={})
  	  if !options.include?(:recipients) || [nil, "", []].include?(options[:recipients])
  		  raise TemplateMailerError, "No recipients specified for email."
  		end
  		Pony.mail(send_settings(options))
  	end
  	alias :dispatch :send

  private

    # This method assembles a Hash of configuration settings to be given to the
    # Pony library to dispatch an email.
    #
    # ==== Parameters
    # settings::  A Hash of the base server settings to be used when putting\
    #             the complete settings together.
    def send_settings(settings)
    	output             = {to: settings[:recipients]}
    	output[:subject]   = settings[:subject]
    	output[:html_body] = @html if (@html || "") != ""
    	output[:body]      = @text if (@text || "") != ""
      output[:from]      = settings[:from] if settings.include?(:from)
      output.merge(pony_settings(settings))
    end

    # This method is used internally to assemble configuration settings that are
    # specific to dispatching an email via SMTP through the Pony library.
    def pony_settings(settings)
    	output = {via: @via}
  		output[:via_options] = @server if @via == :smtp
    	output
    end
  end
end