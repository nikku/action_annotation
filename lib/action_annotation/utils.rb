# = lib/annotations/utils.rb
#
# Provides some methods that are needed at several locations in the plug-in.
#

# = ActionAnnotation::Utils
#
class ActionAnnotation::Utils

  PARSE_REGEXP =
    #  ACTION  any  RESOURCE     (in|from|by)   SOURCE
    /^([_\w]+)(.*\s([_\w]+))?(\s+(in|from|by)\s+(\S+))?$/ # :nodoc:

  # Parses a description string
  # * +description+ description of a controller action
  # * +allow_source+ if false, an exception is raised if the description
  #   contains a variable
  # Returns action, resource and source.
  # See ActionAnnotation::Annotations::ClassMethods for details.
  #
  def self.parse_description(description,allow_source=true)
    # description = "shows all courses in @courses (ignore this comment)"
    action, resource, source = get_tokens(description)
    # 'shows', 'courses', '@courses'
    if source
      raise ArgumentError, "Found unexpected source in '#{description}'" unless allow_source
      source = (source.last(-1)).to_sym if source.starts_with? ':'
    end
    returning Hash.new do |result|
      result[:action] = infinitive(action).to_sym
      result[:resource] = resource.singularize.to_sym if resource
      result[:source] = source if source
      # { :action => :show, :resource => :course, :source => '@courses' }
    end
  end

  def self.get_tokens(description) # :nodoc:
    description = description.gsub(/\(.*\)/,'').strip
    #description = "shows all courses in @courses"
    matches = PARSE_REGEXP.match(description)
    raise ArgumentError, "'#{description}' could not be matches" unless matches
    [matches[1], matches[3], matches[6]]
  end

  @infinitive_hash = {"is" =>  "be", "has" => "have"} # :nodoc:

  def self.infinitive(verb) # :nodoc:
    @infinitive_hash[verb] ||
        (verb.ends_with?("s") ? verb.first(-1) : verb)
  end

end