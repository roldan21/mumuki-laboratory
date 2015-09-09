require 'spec_helper'

describe 'api controller' do
  include AuthHelper

  let(:token) { ApiToken.create!(description: 'token for testing') }

  before { http_login(token.client_id, token.client_secret) }

  describe Api::ExercisesController do
    context 'when there are no exercises ' do
      before { get :index }
      it { expect(response.body).to eq '{"exercises":[]}' }
    end

    context 'when there are exercises' do
      let!(:exercise_1) { create(:exercise, name: 'exercise_1', id: 1) }
      let!(:exercise_2) { create(:exercise, name: 'exercise_2', id: 2) }

      describe 'when not using filters' do
        before { get :index }
        it { expect(response.body).to eq '{"exercises":[{"id":1,"name":"exercise_1"},{"id":2,"name":"exercise_2"}]}' }
      end

      describe 'when using filters' do
        before { get :index, exercises: [1, 5, 8] }
        it { expect(response.body).to eq '{"exercises":[{"id":1,"name":"exercise_1"}]}' }
      end
    end
  end

  describe Api::GuidesController do
    context 'when there are no guides ' do
      before { get :index }
      it { expect(response.body).to eq '{"guides":[]}' }
    end

    context 'when there are guides' do
      let!(:guide_1) { create(:guide, name: 'guide_1', id: 1, language_id: 1) }

      describe 'when not using filters' do
        before { get :index }
        it { expect(response.body).to eq '{"guides":[{"id":1,"github_repository":"flbulgarelli/mumuki-sample-exercises","name":"guide_1","language_id":1,"path_id":null,"position":null}]}' }
      end
    end
  end
end
