#!/usr/bin/env sh

for email in $sns_emails; do
  echo $email
  aws sns subscribe --topic-arn "$sns_arn" --protocol email --notification-endpoint "$email" --region "$region"
done