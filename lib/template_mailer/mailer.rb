module TemplateMailer
  class Mailer
    include LoggingHelper

    # Constructor for the Mailer class.
    #
    # ==== Parameters
    # options::  A Hash of the options to be used by the Mailer. Recognised
    #            option settings are...
    #              * :directory - The root directory that the mailer will use
    #                when looking for template files. If not specified or if the
    #                value specified does not exist then the current working
    #                directory is assumed to have a subdirectory called templates
    #                and that will be used.
    #              * :logger - The logger to be used by the mailer. Defaults to
    #                using a null logger.
    #              * :server - Configuration details used to talk to the SMTP
    #                server to send emails. See the :via option.
    #              * :via - A indication of the mailing method to be used when
    #                dispatching emails. Viable options are :sendmail (the
    #                default) or :smtp. If :smtp is specified then server
    #                details should also be specified.
    def initialize(options={})
      @logger     = options[:logger]
      @directory  = TemplateDirectory.new(template_directory(options[:directory]))
      @via        = options.fetch(:via, :sendmail)
      @server     = options[:server]
    end
    attr_reader :server, :via

    # Fetches the path to the template directory being used by the mailer.
    def directory
      @directory.path
    end

    # This method creates a new Mailer instance by using the details of the
    # current mailer and extending the directory used with the name passed
    # in.
    #
    # ==== Parameters
    # name::  The name of the folder to be appended to the directory being
    #         used by the mailer that the call is being made on.
    def subdirectory(name)
      Mailer.new(directory: File.join(directory, name.to_s),
                 logger:    log,
                 server:    @server,
                 via:       @via)
    end

    # Generates a MailMessage for a named template in the template directory.
    #
    # ==== Parameters
    # template::  The name of the template to generate the email from.
    # context::   A Hash of the variables to be used when generating the email
    #             templates. Defaults to an empty Hash.
    def generate_mail(template, context={})
      log.debug "Constructing a mail message based on the '#{template}' template."
      factory = TemplateFactory.new(@directory.path, log)
      content = factory.manufacture(template, context)
      MailMessage.new({server: @server, via: @via}.merge(content))
    end

    # This method overrides the default implementation to return true for
    # anything that represents a valid Ruby method name. Everything else
    # is delegated to the parent class.
    def respond_to?(name, all=false)
      method_name?(name) || super
    end

    # This method checks the template directory for a subdirectory for the
    # given name. If a subdirectory is found then the call becomes an
    # equivalent to a call to the subdirectory() method. If template
    # matching the name passed in is instead found then this is equivalent
    # to a call to the generate_mail() method. If all other options are
    # exhausted then the parent class version of this method is invoked.
    def method_missing(name, *arguments, &block)
      if directory_exists?(@directory.path, name.to_s)
        subdirectory(name)
      elsif @directory.exists?(name.to_s)
        generate_mail(name, arguments.empty? ? {} : arguments[0])
      else
        super
      end
    end

  private

    def method_name?(name)
      return /[@$"]/ !~ name.inspect
    end

    def settings
      {directory: @directory.path, engines: @engines.values, logger: log}
    end

    def generate_template(path, context={})
      raise TemplateMailerError, "The '#{path}' template files does not exist." if !File.exist?(path)
      raise TemplateMailerError, "Insufficient permission to read the '#{path}' file." if !File.readable?(path)

      pathname = Pathname.new(path)
      engine   = @engines[Pathname.new(path).extname]
      raise TemplateMailerError, "No template engine configured to process the '#{path}' template file." if engine.nil?

      log.debug "Processing the '#{path}' template file with an instance of the #{engine.class.name} class."
      engine.process(pathname, context)
    end

    def template_directory(path)
      output = File.join(Dir.getwd, "templates")
      if path && path.strip != ""
        if directory_exists?(path)
          output = path
        else
          log.warn "The '#{path}' path either does not exist or is not a directory. Default will be used."
        end
      end
      log.debug "Using '#{output}' as the mailer templates directory."
      output
    end

    def directory_exists?(*components)
      path = File.join(*components)
      File.exist?(path) && File.directory?(path)
    end

    def file_exists?(*components)
      path = path(*components)
      File.exist?(path) && File.file?(path)
    end

    def path(*components)
      File.join(*components)
    end
  end
end
