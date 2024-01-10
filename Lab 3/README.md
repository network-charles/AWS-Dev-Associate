The user_data attached to the EC2 is used to install the codedeploy agent.
For some unknown reasons, condiguring Systems Manager to install the agent using
aws ssm resources keeps failing.

After doing a `terraform apply -auto-approve` wait for a `SUCCEEDED` SNS notification
before visiting the EC2 public IP address.

### CODECOMMIT

To trigger the pipeline again, navigate to the `codedeploy` folder and modify the index.html file. After that, commit your changes.
```
cd codedeploy/
git add index.html 
git commit -m 'Added some files'
git push -u origin master
```

