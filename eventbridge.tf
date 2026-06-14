resource "aws_cloudwatch_event_rule" "eventbridge_rule" {
  name                = var.eventbridge_cloudwatch_rule_name
  description         = "Trigger Lambda at 12:00 PM EST every day. For testing, I'm using a different time closer to the current time in the schedule_expression."
  schedule_expression = "cron(40 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "eventbridge_target" {
  rule      = aws_cloudwatch_event_rule.eventbridge_rule.name
  target_id = var.eventbridge_cloudwatch_target_id
  arn       = aws_lambda_function.lambda_ecri_audit_function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = var.aws_lambda_permission_eventbridge
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_ecri_audit_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.eventbridge_rule.arn
}