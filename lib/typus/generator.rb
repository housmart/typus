module Typus

  def self.generator

    # Create app/controllers/admin if doesn't exist.
    admin_controllers_folder = "#{Rails.root}/app/controllers/admin"
    Dir.mkdir(admin_controllers_folder) unless File.directory?(admin_controllers_folder)

    # Get a list of controllers under `app/controllers/admin`.
    admin_controllers = Dir["#{Rails.root}/vendor/plugins/*/app/controllers/admin/*.rb", "#{admin_controllers_folder}/*.rb"]
    admin_controllers = admin_controllers.map { |i| File.basename(i) }

    # Create app/views/admin if doesn't exist.
    admin_views_folder = "#{Rails.root}/app/views/admin"
    Dir.mkdir(admin_views_folder) unless File.directory?(admin_views_folder)

    # Create test/functional/admin if doesn't exist.
    admin_controller_tests_folder = "#{Rails.root}/test/functional/admin"
    if File.directory?("#{Rails.root}/test")
      Dir.mkdir(admin_controller_tests_folder) unless File.directory?(admin_controller_tests_folder)
    end

    # Get a list of functional tests under `test/functional/admin`.
    admin_controller_tests = Dir["#{admin_controller_tests_folder}/*.rb"]
    admin_controller_tests = admin_controller_tests.map { |i| File.basename(i) }

    # Generate controllers for tableless models.
    resources.each do |resource|

      controller_filename = "#{resource.underscore}_controller.rb"
      controller_location = "#{admin_controllers_folder}/#{controller_filename}"

      if !admin_controllers.include?(controller_filename)

        content = <<-RAW
# Controller generated by Typus, use it to extend admin functionality.
class Admin::#{resource}Controller < TypusController

  ##
  # This controller was generated because you have defined a resource 
  # on <tt>config/typus/XXXXXX_roles.yml</tt> which is a tableless model.
  #
  #     admin:
  #       #{resource}: index
  #

  def index
  end

end
      RAW

        File.open(controller_location, "w+") { |f| f << content }

      end

      # And now we create the view.
      view_folder = "#{admin_views_folder}/#{resource.underscore}"
      view_filename = "index.html.erb"

      if !File.exist?("#{view_folder}/#{view_filename}")
        Dir.mkdir(view_folder) unless File.directory?(view_folder)

        content = <<-RAW
<!-- Sidebar -->

<% content_for :sidebar do %>
<%= typus_block :location => 'dashboard', :partial => 'sidebar' %>
<% end %>

<!-- Content -->

<h2>#{resource.humanize}</h2>

<p>And here we do whatever we want to ...</p>

        RAW

        File.open("#{view_folder}/#{view_filename}", "w+") { |f| f << content}

      end

    end

    # Generate unexisting controllers for resources which are tied to a 
    # model.
    models.each do |model|

      # Controller app/controllers/admin/*
      controller_filename = "#{model.tableize}_controller.rb"
      controller_location = "#{admin_controllers_folder}/#{controller_filename}"

      if !admin_controllers.include?(controller_filename)

        content = <<-RAW
# Controller generated by Typus, use it to extend admin functionality.
class Admin::#{model.pluralize}Controller < Admin::MasterController

=begin

  ##
  # You can overwrite and extend Admin::MasterController with your methods.
  #
  # Actions have to be defined in <tt>config/typus/application.yml</tt>:
  #
  #   #{model}:
  #     actions:
  #       index: custom_action
  #       edit: custom_action_for_an_item
  #
  # And you have to add permissions on <tt>config/typus/application_roles.yml</tt> 
  # to have access to them.
  #
  #   admin:
  #     #{model}: create, read, update, destroy, custom_action
  #
  #   editor:
  #     #{model}: create, read, update, custom_action_for_an_item
  #

  def index
  end

  def custom_action
  end

  def custom_action_for_an_item
  end

=end

end
        RAW

        File.open(controller_location, "w+") { |f| f << content }

      end

      # Test test/functional/admin/*_test.rb
      test_filename = "#{model.tableize}_controller_test.rb"
      test_location = "#{admin_controller_tests_folder}/#{test_filename}"

      if !admin_controller_tests.include?(test_filename) && File.directory?("#{Rails.root}/test")

        content = <<-RAW
require 'test_helper'

class Admin::#{model.pluralize}ControllerTest < ActionController::TestCase

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

end
        RAW

        File.open(test_location, "w+") { |f| f << content }

      end

    end

  end

end