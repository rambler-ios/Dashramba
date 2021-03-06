require_relative 'analyzer_model'

module Analyzer
  class AnalyzerMapper
    def map_response(response, bundle_id)
      priority_violations = response['summary']['numberOfViolationsWithPriority']

      issues = response['violation']
      top_issues_hash = {}
      issues.each { |issue|
        issue_type = issue['rule']
        quantity = top_issues_hash[issue_type] ? top_issues_hash[issue_type] : 0
        quantity += 1
        top_issues_hash[issue_type] = quantity
      }

      top_issues = top_issues_hash.sort{ |issue1, issue2|
        issue2[1] <=> issue1[1]
      }

      model_hash = {
          :id => response['timestamp'],
          :enterprise_bundle_id => bundle_id,
          :number_of_files => response['summary']['numberOfFiles'],
          :number_of_rotten_files => response['summary']['numberOfFilesWithViolations'],
          :number_of_first_priority_issues => priority_violations[0]['number'],
          :number_of_second_priority_issues => priority_violations[1]['number'],
          :number_of_third_priority_issues => priority_violations[2]['number'],
          :number_of_xcode_warnings => response['summary']['numberOfWarnings'],
          :top_issues => top_issues
      }

      result = AnalyzerModel.first(:id => model_hash[:id])
      if result != nil
        result.update(model_hash)
      else
        result = Analyzer::AnalyzerModel.new(model_hash)
      end
      return result
    end
  end
end