### Please note, the templates and scripts in this directory are from a demo and may be outdated.
The maintained code can be found in https://github.com/joehack3r, most likely in the aws repository: [https://github.com/joehack3r/aws](https://github.com/joehack3r/aws)

These instructions may need to be adapted to your own specific needs.

1. Create or upload SSL certificate to AWS certificate manager

2. Fork the repository
3. Edit parameter values. Of particular to note:
	* parameters/vpc.json
		* HomeNetwork CIDR blocks 
	* environment-setup.json
		* HostedZone
		* JenkinsHomeEbsVolume
	* demo.json
		* HostedZone
4. Add confidential file that includes SSL Certificate ARN

5. Create demo environment (15-20 minutes)

  ` ./cloudformation-crud.py environment-setup.json`
6. Jenkins:
  * Install GitHub plugin
  * Create Job
	  * Description:
		  1. Clones the repository from GitHub
		  2. Copies the confidential parameter files from S3
		  3. Runs RegEx to update paths
		  4. Runs the cloudformation-crud.py script
  	* Source Code Management:
		  * GitHub
	  * Additional Behaviors:
		  * Check out to a sub-directory:
			  * source
	  * Build triggers:
		  *  Build when a change is pushed to GitHub
	  * Build:
		  * Execute shell:

				cd source/20160208
				# Need to create/get confidental.json somehow. Here we download from S3
				aws s3 cp s3://my-s3-bucket/confidential.json ./parameters/
				newPath= pwd
				oldPath='~/demos/20160208'
				sed -i "s|$oldPath|$newPath|g" demo.json
				./cloudformation-crud.py demo.json

		* Create WebHook in GitHub:
	    * Repository --> Settings --> Webhooks & services --> Webhooks
			  * Payload URL:
			  	https://jenkins-demo.mydomain.com/github-webhook/
		* Which events would you like to trigger this webhook?
			* Just the push event

7. Wait for stack. The first build of the MyApp-Demo-WebApp stack may take ~10 minutes.

8. Demo! Experiment!! Have fun!!!

9. Cleanup

  `./cloudformation-crud.py demo-delete.json`
  `./cloudformation-crud.py environment-delete.json`
