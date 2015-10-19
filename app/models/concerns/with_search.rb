module WithSearch
  extend ActiveSupport::Concern

  included do
    include PgSearch
    include Spanish_question


    pg_search_scope :full_text_search,self::INDEXED_ATTRIBUTES.deep_merge(using: {tsearch: {prefix: true}})

    #pg_search_scope :full_text_search, self::INDEXED_ATTRIBUTES.deep_merge(using: {tsearch: {prefix: true}})
    #scope :by_full_text, lambda { |q| full_text_search(q) if q.present? }
    scope :by_full_text, lambda { |q| full_text_search(q) if q.present? }



  end


end
