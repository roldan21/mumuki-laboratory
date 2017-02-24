module WithPermissions
  extend ActiveSupport::Concern

  included do
    serialize :permissions, Mumukit::Auth::Permissions
  end

  def make_student_of!(slug)
    permissions.add_permission! :student, slug
  end

  def student_of?(organization)
    permissions.student? organization.slug
  end

  #FIXME may be able to remove now
  def student?
    student_of? Organization
  end

  def teacher?
    permissions.teacher? Organization.slug
  end

  def janitor?
    permissions.janitor? Mumukit::Auth::Slug.any
  end

  def writer?
    permissions.writer? Mumukit::Auth::Slug.any
  end

  def accessible_organizations
    permissions.accessible_organizations.map { |org| Organization.find_by(name: org) }.compact
  end

  def has_accessible_organizations?
    accessible_organizations.present?
  end

end
