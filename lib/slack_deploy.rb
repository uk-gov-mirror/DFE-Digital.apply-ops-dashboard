require 'http'
require_relative 'state'

class SlackDeploy
  def start_deploy
    state = State.new
    pull_requests = Diff.pull_requests_between(state.latest_successfull_build_to('qa').commit_sha, state.latest_successfull_build_to('staging').commit_sha)
    pull_requests_list = pull_requests.map { |author, title| " • #{title} (#{author})" }.join("\n")

    post(
      {
      text: "Start a deploy to staging",
    	blocks: [
    		{
    			"type": "section",
    			"text": {
    				"type": "mrkdwn",
    				"text": "Let's deploy! These are the Pull Requests we're about to deploy: \n\n#{pull_requests_list}",
    			}
    		},
    		{
    			"type": "actions",
    			"elements": [
    				{
    					"type": "button",
    					"text": {
    						"type": "plain_text",
    						"emoji": true,
    						"text": ":rocket: Looks good, let's go"
    					},
    					"style": "primary",
    					"value": "deploy-to-staging"
    				},
    			]
    		}
    	]
    }
    )
  end

  def step_2
    {
      replace_original: true,
      text: "Trigger the deploy to staging",
    	blocks: [
    		{
    			"type": "section",
    			"text": {
    				"type": "mrkdwn",
    				"text": "Ok. Now go to Azure and deploy commit `#{State.new.latest_successfull_build_to('qa').commit_sha}`",
    			}
    		},
    		{
    			"type": "actions",
    			"elements": [
    				{
    					"type": "button",
    					"text": {
    						"type": "plain_text",
    						"emoji": true,
    						"text": "Go to Azure DevOps",
                "url": "https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=325&_a=summary"
    					},
    					"style": "primary",
    					"value": "deploy-to-staging"
    				},
    			]
    		}
    	]
    }
  end

private

  def post(payload)
    defaults = {
      mrkdwn: true,
    }

    HTTP.post(webhook_url, body: defaults.merge(payload).to_json)
  end

  def webhook_url
    ENV.fetch('SLACK_WEBHOOK_URL')
  end
end
