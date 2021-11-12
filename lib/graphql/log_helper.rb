# frozen_string_literal: true

require_relative "log_helper/version"

module Graphql
  class LogHelper
    class << self
      def log_details(request_params)
        selections = parse_query(request_params[:query])&.definitions&.first&.selections
        return {} if selections.blank?

        query_params =
          if request_params[:variables].present?
            query_params_given_variables(selections, request_params[:variables])
          else
            query_params_given_no_variables(selections)
          end

        {
          params: query_params,
          resolvers: resolver_names(selections)
        }
      end

      private

      def query_params_given_variables(selections, variables)
        selections.map do |selection|
          [
            selection.name,
            variables.deep_to_a
          ]
        end
      end

      def query_params_given_no_variables(selections)
        selections.map { |selection| selection_to_array(selection) }
      end

      def resolver_names(selections)
        selections.map(&:name)
      end

      def selection_to_array(selection)
        [
          selection.name,
          if !selection.respond_to?(:value)
            selection.arguments.map { |arg| selection_to_array(arg) }
          elsif selection.value.respond_to?(:arguments)
            selection.value.arguments.map { |arg| selection_to_array(arg) }
          else
            selection.value
          end
        ]
      end

      def parse_query(query)
        return nil if query.blank?

        GraphQL.parse(query)
      rescue GraphQL::ParseError
        nil
      end
    end
  end
end
