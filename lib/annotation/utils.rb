#
# = lib/annotations/utils.rb
#
# Provides some methods that are needed at several locations in the plug-in.
#
class ActionAnnotation::Utils # :nodoc:

  # Parses a description string
  # * +description+ description of a controller action
  # * +allow_binding+ if false, an exception is raised if the description
  #                   contains a variable
  # Returns action, resource and binding.
  # See ActionAnnotation::ActionController::ClassMethods for details.
  #
  def self.parse_description(description,allow_binding=false)
    #description = "shows all courses in @courses (ignore this comment)"
    tokens = description.gsub(/\(.*\)/,'').split
    #tokens = ["shows", "all", "courses", "in", "@courses"]
    has_binding = tokens.last =~ /\A(@|:)/
    if has_binding
      raise "Found unexpected binding in '#{description}'" unless allow_binding
      binding = tokens.pop
      binding = (binding.last(-1)).to_sym if binding.start_with? ':'
      tokens.pop if %w{in from by}.include?(tokens.last)
    end
    # binding = "@courses"
    # tokens = ["shows", "all", "courses"]
    action = infinitive(tokens.first).to_sym
    resource = tokens.last.singularize.to_sym
    # action, resource = :show, :course
    if allow_binding
      [action, resource, binding]
    else
      [action, resource]
    end
  end

  @infinitive_hash = {"is" =>  "be", "has" => "have"}

  def self.infinitive(verb)
    @infinitive_hash[verb] ||
        (verb.ends_with?("s") ? verb.first(-1) : verb)
  end

end