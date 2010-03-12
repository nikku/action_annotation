# = libs/action_annotation/annotations.rb
# Contains the ActionAnnotation::Annotations module.
#

module ActionAnnotation # :nodoc:

  # = ActionAnnotation::Annotations
  # Include this module in your class to enable descriptions.
  # Is already included in ActionController::Base.
  #
  # See ActionAnnotation::Annotations::ClassMethods for more information.
  #
  module Annotations

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end

    # = ActionAnnotation::Annotations::ClassMethods
    #
    # This module contains methods for defining descriptions.
    #
    # == Syntax of descriptions
    #
    # A description always contains an action, which is executed, and optionally
    # a resource type and a source for the resource, on which the action is
    # performed.
    #
    # A description is specified as a string of the form
    #  ACTION (* RESOURCE)? ((in|from|by) SOURCE)?
    # and will be transformed into a corrsponding hash.
    #
    # At any point, comments can be inserted using brackets.
    #
    # === Examples
    # * '*show*' -- { :action => :show }
    # * '*show* *comment*' -- { :action => :show, :resource => :comment }
    # * '*shows* all *comments*' -- { :action => :show, :resource => :comment }
    # * '(if necessary) *show* all new *comments* (of this user)' -- { :action => :show, :resource => :comment }
    # * '*show* a *comment* by :id' -- { :action => :show, :resource => :comment, :source => :id }
    # * '*show* all *comments* in <b>@comments</b>' -- { :action => :show, :resource => :comment, :source => '@comments' }
    # Notice that verbs a transformed into infinitive and resources are singularized.
    # Unless the source starts with a colon, it will be provided as string
    #
    # == Defining descriptions
    #
    # To add an description to a method, use #describe or #desc.
    #
    # Also notice that adding new descriptions at runtime is not possible,
    # once #descriptions_of was
    #
    module ClassMethods

      # This module uses the +method_added+ callback. If this method is
      # overwritten and not called using +super+, +desc+ will not work.
      #
      def method_added(method)
        check_pending_descriptions(method)
        super(method)
      end

      # Adds descriptions to a method, but raises an argument error if the
      # method was already described.
      # * +method+ symbol or string
      # * +descriptions+ list of description strings
      #
      def describe!(method, *descriptions)
        raise_if_already_described! method
        describe method, *descriptions
      end

      # Adds descriptions to a method.
      # * +method+ symbol or string
      # * +descriptions+ list of description strings
      #
      # ==== Example
      #  describe :show, "shows a comment"
      #  def show
      #    @comment = Comment.find(params[:id])
      #  end
      #
      def describe(method, *descriptions)
        plain_descriptions_of(method).push(*descriptions)
      end

      # Adds descriptions to the method that will be defined next.
      # * +descriptions+ list of description strings
      #
      # ==== Example
      #  desc "shows a comment"
      #  def show
      #    @comment = Comment.find(params[:id])
      #  end
      #
      def desc(*descriptions)
        unassigned_descriptions.push(*descriptions)
      end

      # Returns the description strings that were added to a method, returns an
      # empty array if no descriptions were provided.
      # * +method+ symbol or string
      #
      def plain_descriptions_of(method)
        plain_descriptions[method.to_sym]
      end

      def plain_descriptions # :nodoc:
        @plain_descriptions ||= Hash.new do |h,k|
          h[k] = fetch_inherited(k)
        end
      end

      # Returns the descriptions that were added to a method, returns an empty
      # array if no descriptions were provided.
      # * +method+ symbol or string
      #
      # ==== Example
      #  desc "shows a comment"
      #  def show
      #    @comment = Comment.find(params[:id])
      #  end
      #
      #  descriptions_of(:show) # == { :action => :show, :resource => :comment }
      #
      def descriptions_of(method)
        parsed_descriptions[method.to_sym]
      end

      def parsed_descriptions # :nodoc:
        @parsed_descriptions ||= Hash.new do |h,k|
          h[k] = parse_descriptions(k)
        end
      end

    private

      def fetch_inherited(method) # :nodoc:
        if superclass.respond_to? :plain_descriptions_of
          return superclass.plain_descriptions_of(method).dup
        end
        []
      end

      def parse_descriptions(method) # :nodoc:
        plain_descriptions_of(method).collect \
            { |desc| ActionAnnotation::Utils.parse_description(desc, true) }
      end

      def check_pending_descriptions(method) # :nodoc:
        unless @unassigned_descriptions.nil?
          describe method, *@unassigned_descriptions
          @unassigned_descriptions = nil
        end
      end

      def unassigned_descriptions # :nodoc:
        @unassigned_descriptions ||= []
      end

      def raise_if_already_described!(method) # :nodoc:
        unless plain_descriptions_of(method).empty?
          raise ArgumentError, "Description for '#{method}' already set"
        end
      end

    end

    # = ActionAnnotation::Annotations::InstanceMethods
    #
    # Contains methods for fetching the value as defined by the source-part
    # of a description.
    #
    module InstanceMethods

      # Returns a list of values that is associated with a source
      # * +source+ Either a symbol or an evaluatable string
      #
      def values_of_source(source)
        value = value_of_source(source)
        # TODO: what happens in case of a hash?
        value.is_a?(Array) ? value : [value]
      end

      # Returns the value that is associated with a source
      # * +source+ Either a symbol or an evaluatable string
      #
      #  value_of_binding(:id)      # == params[:id]
      #  value_of_binding("@value") # == @value
      #
      def value_of_source(source)
        if source.is_a? String
          instance_eval(source)
        elsif source.is_a? Symbol
          params[source]
        else
          raise ArgumentError, "Unknown source #{source}"
        end
      end

    end

  end
end
