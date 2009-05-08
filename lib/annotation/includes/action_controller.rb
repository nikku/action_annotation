#
# = libs/annotation/includes/action_controller.rb
#
# Provides static method description for controllers.
#
#
module ActionAnnotation::ActionController # :nodoc:

  def self.included(base) # :nodoc:

    base.extend(ClassMethods)
    base.send :include, InstanceMethods
  end

  #
  # = libs/annotation/includes/action_controller.rb
  #
  # This module extends ActionController::Base to enable action descriptions.
  #
  # == Syntax of descriptions
  #
  # === Basic Syntax
  # A basic description has the form <tt>ACTION on RESOURCE</tt>, where
  # * +ACTION+ is a verb, either in infinitive or in 3rd person and 
  # * +RESOURCE+ defines the resource on which the action is performed,
  #   either in singular or plural.
  # To improve readability, between action and resource any words may be
  # inserted.
  # ==== Examples
  # * "*show* all *comments*" # action => show, resource => comment
  # * "*sends* an *email*" # action => send, resource => email
  # * "*deletes* the currently selected *user*"
  #   # action => delete, resource => user
  #
  # === Bindings
  # If the resource object has to be stated more precisely, the description can
  # be extended by a binding. A binding can refer either to a request parameter
  # or to an instance variable. Between the resource and the binding, one of the
  # words "in", "from" or "by" may be inserted.
  # ==== Examples
  # * "*shows* *profile* by :*id*"
  #   # action => show, resource => profile, binding => params[:id]
  # * "*lists* all *users* in @*user_list*"
  #   # action => list, resource => user, binding => @user_list
  #
  # === Comments
  # At any point, comments can be inserted using brackets.
  # * "*deletes* the current *user* (if not already done)"
  #   # action => delete, resource => user
  # * "(if confirmed) *adds* the user as *friend* (that has the id) :*id*"
  #   # action => add, resource => friend, binding => params[:id]
  #
  # == Accessing descriptions at runtime
  #
  # There are two methods to access the descriptions that were defined for an
  # action.
  #
  # The method #context_rules_for will return the descriptions of an action
  # that are not bound to a variable or parameter. The result is a hash with
  # the resources as keys and a list of the actions performed on them as values.
  #  describe :write, "create comment", "update comment", "show profile"
  #  c_rules = context_rules_for(:write) # => { :comment => [:create, :update],
  #                                      #      :profile => [:show] }
  #  c_rules[:comment] # => [:create, :update]
  #  c_rules[:user]    # => []
  #
  # With #bounded_rules_for the descriptions with bindings can be accessed. The
  # result is hash with the bindings as keys and resource-action-hashs as
  # values.
  #  describe :write, "create comment in @comment", "update comment in @comment", "show profile by :id"
  #  b_rules = bounded_rules_for(:write) # => { "@comment" => { :comment => [:create, :update] },
  #                                      #      :id        => { :profile => [:show] } }
  #  b_rules[:id]             # => { :profile => [:show] }
  #  b_rules[:id][:profile]   # => [:show]
  #  b_rules[:user_id]        # => { }
  #  b_rules[:user_id][:user] # => []
  #
  module ClassMethods

    # Register descriptions for an action
    #
    # Example:
    #  describe :my_action, "shows a user",
    #                       "shows user_details",
    #                       "lists all comments (for this user)"
    #
    def describe(action_name, *descriptions)
      action_name = action_name.to_sym
      raise_if_already_described action_name
      parse_descriptions(action_name, descriptions)
    end

    # Return the context rules for an action
    # * +action_name+ name of the action
    #
    # Returns a hash { :resource_type => [:action] }
    #
    def context_rules_for(action_name)
      context_rules[action_name.to_sym]
    end

    # Return the rules that are bound to a variable
    # * +action_name+ name of the action
    #
    # Returns a hash { binding => { :resource_type => [:action] } },
    # where +binding+ is either a symbol or a string.
    # Use #value_of_binding to get the bindings value.
    #
    def bounded_rules_for(action_name)
      bounded_rules[action_name.to_sym]
    end

    # Hash of action => rules for all rules that are bound to
    # a variable
    # :action => {:variable => {:res_class => [:rights]}}
    def bounded_rules # :nodoc:
      @bounded_rules ||= new_bounded_rule_hash
    end

    # Hash of action => rules for all rules that are not bound to
    # a variable
    # :action => {:res_class => [:rights]}
    def context_rules # :nodoc:
      @context_rules ||= new_context_rule_hash
    end

    private

    # Returns empty hash prepared for the form
    # :action => {:variable => {:res_class => [:rights]}}
    def new_bounded_rule_hash
      # :action of the context rule hash becomes :variable
      Hash.new {|h,k| h[k] = new_context_rule_hash }
    end

    # Returns empty hash prepared for the form
    # :action => {:res_class => [:right]}
    def new_context_rule_hash
      Hash.new {|h,k| h[k] = new_rule_hash }
    end

    # Returns empty hash prepared for the form
    # :res_class => [:right]
    def new_rule_hash
      Hash.new {|i,l| i[l] = [] }
    end

    def raise_if_already_described(action)
      unless bounded_rules[action].blank? && context_rules[action].blank?
        raise ArgumentError, "Description for '#{action}' already set"
      end
    end

    def parse_descriptions(action, descriptions)
      _bounded_rules = new_context_rule_hash
      _context_rules = new_rule_hash

      #descriptions = [["show all courses in @my_courses"],...]
      descriptions.each do |desc|
        right,resource,binding = AnnotationSecurity::Utils.parse_description(desc,true)
        # :show, :course, :@my_courses
        if binding
          _bounded_rules[binding][resource] << right
          # { :@my_courses => { :course => [:show,...] } }
        else
          _context_rules[resource] << right
          # { :course => [:show,...] }
        end
      end

      bounded_rules[action] = _bounded_rules
      # { :action => { :@my_course => [[:show, :course],...] } }
      context_rules[action] = _context_rules
      # { :action => { :course => [:show, ...] } }
    end

  end

  #
  # = libs/annotation/includes/action_controller.rb
  # 
  module InstanceMethods


    def values_of_binding(binding) # :nodoc:
      value = value_of_binding(binding)
      value.is_a?(Array) ? value : [value]
    end

    # Returns the value that is associated with a binding
    # * +binding+ Either a symbol or an evaluatable string
    #
    #  value_of_binding(:id)      # == params[:id]
    #  value_of_binding("@value") # == @value
    #
    def value_of_binding(binding)
      if binding.is_a? String
        instance_eval(binding)
      elsif binding.is_a? Symbol
        params[binding]
      else
        raise ArgumentError, "Unknown binding #{binding}"
      end
    end

  end
end