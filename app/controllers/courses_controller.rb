class CoursesController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @course = current_user.courses.build(course_params)
    if @course.save
      flash[:success] = 'Couse created'
    else
      flash[:error] = 'Course not created'
    end
    redirect_to current_user
  end

  def destroy
  end

  def generate_messages
    @course = current_user.courses.find_by(id: params[:id])
    @course.generate_messages
    redirect_to current_user
  end

  private

    def course_params
      params.require(:course).permit(:id,:name, :concepts, :activity_log, :student_generated_content)
    end
end
