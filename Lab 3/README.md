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

### CODEDEPLOY
<img width="888" alt="Screenshot 2024-01-10 at 3 28 48 PM" src="https://github.com/network-charles/AWS-Dev-Associate/assets/30233365/48d66b4d-9cda-4d1e-bb50-33499640e1b4">
