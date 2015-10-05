class Exercise < ActiveRecord::Base
  INDEXED_ATTRIBUTES = {

      against: [:name, :description],
      associated_against: {
          language: [:name],
          tags: [:name],
          guide: [:name]
      },
  }

  include WithSearch,
          WithTeaser,
          WithMarkup,
          WithAuthor,
          WithAssignments,
          WithGuide,
          WithLocale,
          WithLanguage,
          WithLayout,
          WithSlug,
          Submittable,
          Queriable

  acts_as_taggable

  after_initialize :defaults, if: :new_record?

  validates_presence_of :name, :description, :language,
                        :submissions_count, :author

  scope :by_tag, lambda { |tag| tagged_with(tag) if tag.present? }

  markup_on :description, :hint, :teaser, :corollary

  def self.create_or_update_for_import(guide, original_id, options)
    clazz = Kernel.const_get(options[:type])
    exercise = clazz.find_or_initialize_by(original_id: original_id, guide_id: guide.id)
    exercise.assign_attributes(options)
    exercise.save
    exercise
  rescue => e
    exercise.errors.add :base, e.message
    exercise
  end

  def search_tags
    tag_list + [language.name]
  end

  def generate_original_id!
    update!(original_id: id) unless original_id
  end

  def collaborator?(user)
    guide.present? && guide.authored_by?(user)
  end

  def extra_code
    [guide.try(&:extra_code), self[:extra_code]].compact.join("\n")
  end

  private

  def defaults
    self.submissions_count = 0
    self.layout = Exercise.default_layout
  end

  def self.default_layout
    layouts.keys[0]
  end

  def generate_custom_slug
    if guide
      "#{guide.name}-#{position}-#{name}"
    else
      name
    end
  end
end
