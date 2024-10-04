resource "aws_lambda_function" "this" {
  for_each = { for k, v in var.lambda_info : k => v }

  function_name    = each.value.lambda_function_name
  role             = each.value.lambda_function_role_arn
  runtime          = each.value.lambda_function_runtime
  architectures    = [each.value.lambda_function_architectures]
  handler          = each.value.lambda_function_handler
  timeout          = each.value.lambda_function_timeout
  filename         = data.archive_file.this[each.key].output_path
  source_code_hash = data.archive_file.this[each.key].output_base64sha256

  environment {
    variables = each.value.lambda_function_env_var
  }

  layers = [aws_lambda_layer_version.this[each.key].arn]
  tags   = each.value.lambda_function_tags
}

data "archive_file" "this" {
  for_each    = { for k, v in var.lambda_info : k => v }
  type        = "zip"
  output_path = "./lambda/zip/${each.value.lambda_payload_file_dir}.zip"
  source_dir  = "./lambda/payload/${each.value.lambda_payload_file_dir}"
}

# Lambda 함수를 호출하는 데 필요한 권한을 추가
resource "aws_lambda_permission" "this" {
  for_each      = { for k, v in var.lambda_info : k => v }
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${each.value.lambda_function_trigger_id}"
}


resource "aws_s3_bucket_notification" "this" {
  for_each = { for k, v in var.lambda_info : k => v if v.lambda_function_trigger_type == "s3" }

  bucket = each.value.lambda_function_trigger_id
  lambda_function {
    lambda_function_arn = aws_lambda_function.this[each.key].arn
    events              = ["s3:ObjectCreated:*"]
  }
}


resource "aws_lambda_layer_version" "this" {
  for_each = { for k, v in var.lambda_info : k => v if v.lambda_function_layer_name != "" }

  filename                 = "./lambda/layer/${each.value.lambda_function_layer_file_name}"
  layer_name               = each.value.lambda_function_layer_name
  compatible_runtimes      = [each.value.lambda_function_layer_runtime]
  compatible_architectures = [each.value.lambda_function_layer_architectures]

}