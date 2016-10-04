class Atheneum::Command::UpsertExam
  def self.execute!(body)
    import_from_json! body
  end

  def self.import_from_json!(json)
    organization = Organization.find_by!(name: json.delete('tenant'))
    organization.switch!
    exam_data = parse_json json
    users = exam_data.delete('users')
    exam = Exam.where(classroom_id: exam_data.delete('id')).update_or_create! exam_data
    exam.process_users users
    exam.index_usage! organization
    exam
  end

  def self.parse_json(exam_json)
    exam = exam_json.except('name', 'language')
    exam['guide_id'] = Guide.find_by(slug: exam.delete('slug')).id
    exam['organization_id'] = Organization.id
    exam['users'] = exam.delete('social_ids').map { |sid| User.find_by(uid: sid) }.compact
    ['start_time', 'end_time'].each { |param| exam[param] = exam[param].to_time }
    exam
  end
end