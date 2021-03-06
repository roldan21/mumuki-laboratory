module Status
  STATUSES = [Pending, Running, Passed, Failed, Errored, Aborted, PassedWithWarnings, ManualEvaluationPending]

  def self.load(i)
    STATUSES[i]
  end

  def self.dump(status)
    coerce(status).to_i
  end

  def self.from_sym(status)
    "Status::#{status.to_s.camelize}".constantize
  end

  def self.coerce(status_like)
    if status_like.is_a? Symbol
      from_sym(status_like)
    elsif status_like.is_a? Status::Base
      status_like
    else
      status_like.status
    end
  end
end
