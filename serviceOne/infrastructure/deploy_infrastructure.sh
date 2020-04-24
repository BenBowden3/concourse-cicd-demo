#!/bin/sh

# Directories created for passing input/output between tasks
SETTINGS=../../../settings
TFOUTPUT=../../../tfoutput

SERVICE="serviceOne"

ENV_NAME=`jq -r .environment $SETTINGS/settings.json`
STATE_BUCKET=`jq -r .stateBucket $SETTINGS/settings.json`
TF_STATE_KEY=`jq -r .tfStateKey $SETTINGS/settings.json`
REGION=`jq -r .region $SETTINGS/settings.json`
ROLE_ARN=`jq -r .roleArn $SETTINGS/settings.json`

aws cloudformation create-stack \
--region us-east-2 \
--stack-name $ENV_NAME-$SERVICE \
--template-body file://cloudformation.yaml \
--role-arn $ROLE_ARN \
--parameters ParameterKey=environment,ParameterValue=$ENV_NAME

sleep 30

DYNARN=$(aws cloudformation describe-stacks --region us-east-2 --stack-name $SERVICE | jq -r '.Stacks[0].Outputs[0].OutputValue')
KINARN=$(aws cloudformation describe-stacks --region us-east-2 --stack-name $SERVICE | jq -r '.Stacks[0].Outputs[1].OutputValue')

jq -n --arg dyn "$DYNARN" --arg kin "$KINARN" '{"dynamo_table":$dyn, "kinesis_stream":$kin}' > $TFOUTPUT/output.json