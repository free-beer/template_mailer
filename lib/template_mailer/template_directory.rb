module TemplateMailer
  class TemplateDirectory
    include LoggingHelper

    # Constructor for the TemplateDirectory class.
    #
    # ==== Parameters
    # path::    The path to the template directory.
    # logger::  The logger to be used by the directory object.
    def initialize(path,logger=nil)
      @pathname   = Pathname.new(path)
      @logger     = logger
      scan_templates
    end
    attr_reader :pathname, :engines, :extensions

    # Returns a String containing the template directory path.
    def path
      @pathname.to_s
    end

    # Returns an array of the template files within the directory.
    def template_files
    	[].concat(@templates)
    end

    # Checks whether at least one template file with a given name exists within
    # the template directory.
    #
    # ==== Parameters
    # name::  The name of the template. This should be the file name, not
    #         including base path details or extensions.
    def exists?(name)
    	!template_paths(name).empty?
    end

    # Retrieves a list of paths for all template files within a template
    # directory that match a given template name.
    #
    # ==== Parameters
    # name::  The name of the template. This should be the file name, not
    #         including base path details or extensions.
    def template_paths(name)
    	@templates.inject([]) do |list, path|
    		file_name = File.basename(path)
    		file_name[0, name.length] == name.to_s ? list << path : list
    	end
    end

  private

    # Scans the files in the template directory to generate a list of files
    # recognised as templates based on extensions from the object itself and
    # the engine it possesses.
    def scan_templates
    	@templates = Dir.glob(File.join(path, "*")).inject([]) do |list, file_path|
        log.debug "Checking if #{file_path} is a recognised template file."
        file_name = File.basename(file_path)
        log.debug "#{file_path} is a template file." if !(Tilt[file_name]).nil?
        list << file_path if !(Tilt[file_name]).nil?
        list
    	end
    end
  end
end
