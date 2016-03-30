module TemplateMailer
  class TemplateFactory
  	include LoggingHelper

  	# Constructor for the template factory class.
  	#
  	# ==== Parameters
  	# directory::   The path to the directory containing the template files.
    # logger::      The logger to be used by the factory. Defaults to nil.
  	def initialize(directory, logger=nil)
  		@directory = TemplateDirectory.new(directory, logger)
  		@logger    = logger
    end

    # Fetches the template directory being used by the factory.
    def directory
    	@directory.path
    end

    # Checks whether one or more template files exist for a given name.
    #
    # ==== Parameters
    # name::  The name of the template to check for. A template name should be
    #         the template file name without extension(s).
    def exists?(name)
    	@directory.exists?(name)
    end

    # This method 'manufactures' a set of templates based on the template name.
    # Manufacturing involves finding all instance of a template and then using
    # the template engine to generate the results of the template including the
    # elements of the context passed in. The return value from this method will
    # be a Hash of the templates generated (there may be more than one) keyed
    # on the base file types used to generate the template instance. If a
    # matching template cannot be found then an empty Hash is returned.
    #
    # ==== Parameters
    # name::     The name of the template to manufacture. Template names equate
    #            to template file names minus extensions.
    # context::  A Hash of settings that will be made available to the template
    #            engine when the template is instantiated. Defaults to {}. 
    def manufacture(name, context={})
      paths = @directory.template_paths(name)
    	log.debug "Manufacture requested for the '#{name}' template. Context:\n#{context}\nFound #{paths.size} matching template files."
    	paths.inject({}) do |store, path|
    		key    = file_base_type(path)
        engine = Tilt.new(path)
    		log.debug "Generating template for the #{path} template file as type '#{key}'."
    		store[key] = engine.render(nil, context)
    		store
    	end
    end

    # Same as the manufacture() method except this version raises an exception
    # if no matching templates are found.
    #
    # ==== Parameters
    # name::     The name of the template to manufacture. Template names equate
    #            to template file names minus extensions.
    # context::  A Hash of settings that will be made available to the template
    #            engine when the template is instantiated. Defaults to {}. 
    def manufacture!(name, context={})
    	output = manufacture(name, context)
    	raise TemplateMailerError, "Unable to locate a template with the name '#{name}'." if output.empty?
    	output
    end

  private

    # Generate a Symbol based on the base type for a file. The base type for
    # template files will be the first extension that the file has rather than
    # the second (e.g. :html for a file called template.html.erb).
    #
    # ==== Parameters
    # path::  The path and name of the template file to generate the base type
    #         for.
    def file_base_type(path)
  		file_name = File.basename(path)
  		extension = File.extname(file_name)
  		file_name = file_name[0, file_name.length - extension.length]
  		(File.extname(file_name)[1..-1]).to_sym
    end
  end
end
