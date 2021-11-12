# frozen_string_literal: true

RSpec.describe Graphql::LogHelper, type: :request do
  before do
    allow(Rails.logger).to receive(:info)
    subject
  end

  let(:formatted_expected_log_output) do
    Regexp.new(
      Regexp.quote(
        expected_log_output.to_json[1...-1]
      )
    )
  end

  subject { post(graphql_path(request_paylod)) }

  context 'without query variables' do
    context 'without nested arguments' do
      let(:request_paylod) do
        {
          params: {
            query: <<-QUERY
              query {
                books(authorId: 1) {
                  id
                }
              }
            QUERY
          }
        }
      end

      let(:expected_log_output) do
        {
          params: [['books', [['authorId', 1]]]],
          resolvers: ['books']
        }
      end

      it 'logs the resolver name and params' do
        expect(Rails.logger).to have_received(:info).with(formatted_expected_log_output)
      end
    end

    context 'with nested arguments' do
      let(:request_paylod) do
        {
          params: {
            query: <<-QUERY
              query {
                chapter(
                  storyAttributes: {
                    charCount: 1
                    paragraphs: 2
                    wordCount: 3
                  }
                ) {
                  predictedWasteFactor
                }
              }
            QUERY
          }
        }
      end

      let(:expected_log_output) do
        {
          params: [
            ['chapter',
              [
                ['storyAttributes',
                [
                  ['charCount', 1],
                  ['paragraphs', 2],
                  ['wordCount', 3]
                ]]
              ]]
          ],
          resolvers: ['chapter']
        }
      end

      it 'logs the resolver name and params' do
        expect(Rails.logger).to have_received(:info).with(formatted_expected_log_output)
      end
    end

    context 'with multiple queries' do
      let(:request_paylod) do
        {
          params: {
            query: <<-QUERY
              query {
                books(authorId: 1) {
                  id
                }
                chapter(
                  storyAttributes: {
                    charCount: 1
                    paragraphs: 2
                    wordCount: 3
                  }
                ) {
                  predictedWasteFactor
                }
              }
            QUERY
          }
        }
      end

      let(:expected_log_output) do
        {
          params: [
            ['books', [['authorId', 1]]],
            ['chapter',
              [
                ['storyAttributes',
                [
                  ['charCount', 1],
                  ['paragraphs', 2],
                  ['wordCount', 3]
                ]]
              ]]
          ],
          resolvers: %w[books chapter]
        }
      end

      it 'logs the resolver names and params' do
        expect(Rails.logger).to have_received(:info).with(formatted_expected_log_output)
      end
    end
  end

  context 'with query variables' do
    context 'without nested arguments' do
      let(:request_paylod) do
        {
          params: {
            variables: { authorId: 1 },
            query: <<-QUERY
              query books($authorId: ID!) {
                books(authorId: $authorId) {
                  id
                }
              }
            QUERY
          }
        }
      end

      let(:expected_log_output) do
        {
          params: [['books', [%w[authorId 1]]]],
          resolvers: ['books']
        }
      end

      it 'logs the resolver name and params' do
        expect(Rails.logger).to have_received(:info).with(formatted_expected_log_output)
      end
    end

    context 'with nested arguments' do
      let(:request_paylod) do
        {
          params: {
            variables: {
              storyAttributes: {
                charCount: 1,
                paragraphs: 2,
                wordCount: 3
              }
            },
            query: <<-QUERY
              query wasteFactorRoof($storyAttributes: WasteFactorRoofInput!) {
                wasteFactorRoof(storyAttributes: $storyAttributes) {
                  predictedWasteFactor
                }
              }
            QUERY
          }
        }
      end

      let(:expected_log_output) do
        {
          params:
            [['wasteFactorRoof',
              [
                ['storyAttributes',
                  [
                    %w[charCount 1],
                    %w[paragraphs 2],
                    %w[wordCount 3]
                  ]]
              ]]],
          resolvers: ['wasteFactorRoof']
        }
      end

      it 'logs the resolver name and params' do
        expect(Rails.logger).to have_received(:info).with(formatted_expected_log_output)
      end
    end

    context 'with multiple queries' do
      let(:request_paylod) do
        {
          params: {
            variables: {
              authorId: 1,
              storyAttributes: {
                charCount: 1,
                paragraphs: 2,
                wordCount: 3
              }
            },
            query: <<-QUERY
              query ($authorId: ID!, $storyAttributes: WasteFactorRoofInput!) {
                books(authorId: $authorId) {
                  id
                }
                wasteFactorRoof(storyAttributes: $storyAttributes) {
                  predictedWasteFactor
                }
              }
            QUERY
          }
        }
      end

      let(:expected_log_output) do
        {
          params:
          [
            ['books',
              [%w[authorId 1],
              ['storyAttributes',
                [
                  %w[charCount 1],
                  %w[paragraphs 2],
                  %w[wordCount 3]
                ]]]],
            ['wasteFactorRoof',
              [%w[authorId 1],
              ['storyAttributes',
                [
                  %w[charCount 1],
                  %w[paragraphs 2],
                  %w[wordCount 3]
                ]]]]
          ], resolvers: %w[books wasteFactorRoof]
        }
      end

      it 'logs the resolver name and params' do
        expect(Rails.logger).to have_received(:info).with(formatted_expected_log_output)
      end
    end
  end
end
