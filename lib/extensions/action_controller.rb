# = lib/extensions/action_controller.rb
#
# Extends ActionController::Base to enable action descriptions.
#

module ActionController # :nodoc:

  class Base # :nodoc:

    include ::ActionAnnotation::Annotations

  end

end