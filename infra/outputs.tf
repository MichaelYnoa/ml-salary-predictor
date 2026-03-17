# infra/outputs.tf
# Define qué información muestra Terraform después del deploy.
# Sin esto tendrías que entrar a la consola de AWS a buscar la IP.
# Con esto aparece directamente en tu terminal.

output "instance_public_ip" {
  description = "Public IP of the salary predictor server"
  value       = aws_instance.salary_predictor.public_ip
}

output "api_url" {
  description = "Direct URL to the prediction API"
  value       = "http://${aws_instance.salary_predictor.public_ip}:8000"
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = "http://${aws_instance.salary_predictor.public_ip}:8000/health"
}