### Please note, the templates and scripts in this directory are from a demo and may be outdated.
If the code is maintained, it can be found in https://github.com/joehack3r, most likely in the aws repository: [https://github.com/joehack3r/aws](https://github.com/joehack3r/aws)

These instructions may need to be adapted to your own specific needs.

1. Upload one of both zip files to your S3 bucket

2. Create a CloudFormation stack using the lambdaTerminateInstancesWithEvents.json template

3. Create a [CloudWatch Events Rule](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#rules:)
	* Event selector (event source)
		* Schedule
	* Targets
		* Lambda function
