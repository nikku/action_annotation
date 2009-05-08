
module ActionController # :nodoc:

  #
  # = lib/extensions/action_controller.rb
  #
  # Extends ActionController::Base to enable action descriptions.
  #
  class Base # :nodoc:

    include ::ActionAnnotation::ActionController

  end

end