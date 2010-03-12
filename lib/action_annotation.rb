# = libs/action_annotation.rb
# This file contains the require definitions for this gem.
#

module ActionAnnotation # :nodoc:
end

dir = File.dirname(__FILE__)
require dir + "/action_annotation/utils"
require dir + "/action_annotation/annotations"
require dir + "/extensions/action_controller"