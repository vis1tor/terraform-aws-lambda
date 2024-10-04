##################################
# Lambda Function
##################################
variable "lambda_info" {
  type = map(object({
    lambda_function_name                = string
    lambda_function_role_arn            = string
    lambda_function_runtime             = string
    lambda_function_architectures       = string
    lambda_function_handler             = string
    lambda_function_timeout             = string
    lambda_function_tags                = map(string)
    lambda_function_env_var             = map(string)
    lambda_payload_file_dir             = string
    lambda_function_trigger_type        = string
    lambda_function_trigger_id          = string
    lambda_function_layer_name          = string
    lambda_function_layer_file_name     = string
    lambda_function_layer_runtime       = string
    lambda_function_layer_architectures = string
    })
  )
}

# variable "lambda_payload_zip_file" {
#   type = any
# }