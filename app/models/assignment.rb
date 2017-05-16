class Assignment < ActiveRecord::Base
  include WithStatus

  belongs_to :exercise
  has_one :guide, through: :exercise

  belongs_to :submitter, class_name: 'User'

  validates_presence_of :exercise, :submitter

  serialize :expectation_results
  serialize :test_results

  delegate :language, :name, :visible_success_output?, to: :exercise
  delegate :output_content_type, to: :language
  delegate :should_retry?, to: :status

  scope :by_exercise_ids, -> (exercise_ids) {
    where(exercise_id: exercise_ids) if exercise_ids
  }

  scope :by_usernames, -> (usernames) {
    joins(:submitter).where('users.name' => usernames) if usernames
  }

  def results_visible?
    visible_success_output? || should_retry?
  end

  def result_preview
    result.truncate(100) if should_retry?
  end

  def result_html
    output_content_type.to_html(result)
  end

  def feedback_html
    output_content_type.to_html(feedback)
  end

  def expectation_results_visible?
    visible_expectation_results.present?
  end

  def visible_expectation_results
    StatusRenderingVerbosity.visible_expectation_results(status, expectation_results || [])
  end

  def accept_new_submission!(submission)
    transaction do
      update! submission_id: submission.id
      update_submissions_count!
      update_last_submission!
    end
  end

  def comments
    Comment.where(submission_id: submission_id).order('date DESC')
  end

  def comment!(comment_data)
    Comment.create! comment_data.merge(submission_id: submission_id, exercise_id: exercise_id)
  end

  def extension
    exercise.language.extension
  end

  def notify!
    Mumukit::Nuntius.notify! 'submissions', nuntius_json
  end

  def nuntius_json
    navigable_parent = @assignment.exercise.navigable_parent
    @assignment.
      as_json(except: [:exercise_id, :submission_id, :id, :submitter_id, :solution, :created_at, :updated_at],
              include: {
                guide: {
                  only: [:slug, :name],
                  include: {
                    lesson: {only: [:number]},
                    language: {only: [:name]}},
                },
                exercise: {only: [:name, :number]},
                submitter: {only: [:name, :email, :image_url, :social_id, :uid]}}).
      deep_merge(
        'sid' => @assignment.submission_id,
        'created_at' => @assignment.updated_at,
        'content' => @assignment.solution,
        'exercise' => {
          'eid' => @assignment.exercise.bibliotheca_id
        },
        'guide' => {'parent' => {
          'type' => navigable_parent.class.to_s,
          'name' => navigable_parent.name,
          'position' => navigable_parent.try(:number),
          'chapter' => @assignment.guide.chapter.as_json(only: [:id], methods: [:name])
        }},
        'organization' => Organization.current.name)
  end

  def notify_to_accessible_organizations!
    submitter.accessible_organizations.each do |organization|
      organization.switch!
      notify!
    end
  end

  private

  def update_submissions_count!
    self.class.connection.execute(
        "update public.exercises
         set submissions_count = submissions_count + 1
        where id = #{exercise.id}")
    self.class.connection.execute(
        "update public.assignments
         set submissions_count = submissions_count + 1
        where id = #{id}")
    exercise.reload
  end

  def update_last_submission!
    submitter.update!(last_submission_date: DateTime.now, last_exercise: exercise)
  end
end
