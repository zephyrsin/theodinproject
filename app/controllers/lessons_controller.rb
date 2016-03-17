class LessonsController < ApplicationController

  def index
    # Render a 404 error if we can't find course
    begin
      @course = Course.find_by_title_url!(params[:course_name])
    rescue
      raise ActionController::RoutingError.new('Not Found')
    end

    raise ActionController::RoutingError.new('Not Found') unless @course.is_active

    @lessons = @course.lessons.order("position asc")
    @sections = @course.sections.order("position asc").includes(:lessons)
  end

  def show
    # Render a 404 error if we can't find course or lesson
    begin
      @course = Course.find_by_title_url!(params[:course_name])
      @lesson = @course.lessons.find_by_title_url!(params[:lesson_name])
    rescue
      raise ActionController::RoutingError.new('Not Found')
    end

    raise ActionController::RoutingError.new('Not Found') unless @course.is_active

    @content = md(@lesson.content) if @lesson.content
    @next_lesson = @lesson.next_lesson
    @prev_lesson = @lesson.prev_lesson
    @num_lessons = @lesson.section.lessons.where(:is_project => false).count
    @num_projects = @lesson.section.lessons.where(:is_project => true).count

    #SPIKE! These two queries run the logic we want - but are by no means final.
    #TODO: Write tests, rewrite this crap :)
    # @completion_ids = @lesson.lesson_completion_ids
    # @current_students = @prev_lesson.lesson_completion_ids.find_all do |completion_id|
    #   User.find(completion_id).send(:latest_completed_lesson).id == @prev_lesson.id
    # end

    # the position of the lesson not including projects
    @lesson_position_in_section = @lesson.section.lessons.where("is_project = ? AND position <= ?", false, @lesson.position).count
    # puts "\n\nVE BANNER #{Ad.show_ads?(current_user)}!\n\n"
    # puts "ENV: #{ENV['SHOW_ADS']}!!\n\n"
    if ENV["SHOW_ADS"] && Ad.show_ads?(current_user)
      @lower_banner_ad = true # Ad.ve_banner
      @right_box_ad = true # Ad.ve_box
    end
    # puts "\n\nVE: #{Ad.all.inspect} \n\nBANNER AD #{Ad.ve_banner}!\n\n"
  end

end
