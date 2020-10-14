# EventDrivenPythonAWS
This repository is created for creating an event driven Python ETL processing in AWS of COVID-19 US data.

## Prereqisites

1. Create a bucket to store terraform state.

2. Create secrets in Secret Manager. Use secret tye as "Other type of secrets"

## Steps

1. Update backend.tf file with your unique bucket name and you can region as well.

2. Update inputs.tfvar file with your inputs. Use above created secret manager in secret name.

3. Run bellow scripts
```
terraform init

terraform plan

terraform apply

```

4. Test failed scenario by updating wrong file name as input. First lambda function will fail to dowloand the file and send email to susbcribed users of ERROR topic.

5. You can pass another valid URL but not the same as our source. In this case, our download lambda would be succesfull but ETL lambda will fail and send notification to susbcribed users of ERROR topic.

6. Run below command to trigger DOWNLOAD lambda function manually and then further it will trigger ETL and load data into Database and send notification to susbcribed users of SUCCESS topic.