require 'spec_helper'

describe Playground do
  let(:user) { create(:user) }

  before { I18n.locale = :en }

  describe '#create' do
    context 'when language is queriable and exercise is playable' do
      let(:language) { create(:language, queriable: true) }
      let(:exercise) { build(:playground, language: language, layout: :editor_bottom) }

      it { expect(exercise.save).to be true }
    end

    context 'when language is not queriable and exercise is playable' do
      let(:language) { create(:language, queriable: false) }
      let(:exercise) { build(:playground, language: language, layout: :editor_bottom) }

      it { expect(exercise.save).to be false }
    end

    context 'when language is queriable and exercise is not playable' do
      let(:language) { create(:language, queriable: true) }
      let(:exercise) { build(:playground, language: language, layout: :scratchy) }

      it { expect(exercise.save).to be false }
    end
  end

end