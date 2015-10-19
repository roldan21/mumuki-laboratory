
class Spanish_question < ActiveRecord::Base
  include PgSearch
  pg_search_scope :gringo_search,
                  :against => :word,
                  :ignoring => :accents
end

