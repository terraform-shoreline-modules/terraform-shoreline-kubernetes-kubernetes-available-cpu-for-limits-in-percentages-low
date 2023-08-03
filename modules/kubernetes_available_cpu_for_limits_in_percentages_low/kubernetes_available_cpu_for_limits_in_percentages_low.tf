resource "shoreline_notebook" "kubernetes_available_cpu_for_limits_in_percentages_low" {
  name       = "kubernetes_available_cpu_for_limits_in_percentages_low"
  data       = file("${path.module}/data/kubernetes_available_cpu_for_limits_in_percentages_low.json")
  depends_on = [shoreline_action.invoke_cpu_limit_alert,shoreline_action.invoke_kubernetes_resource_checker,shoreline_action.invoke_increase_cpu_limits,shoreline_action.invoke_increase_cpu_resources]
}

resource "shoreline_file" "cpu_limit_alert" {
  name             = "cpu_limit_alert"
  input_file       = "${path.module}/data/cpu_limit_alert.sh"
  md5              = filemd5("${path.module}/data/cpu_limit_alert.sh")
  description      = "Heavy load on the Kubernetes cluster which has caused the CPU usage to spike and exceed the limits set in place."
  destination_path = "/agent/scripts/cpu_limit_alert.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kubernetes_resource_checker" {
  name             = "kubernetes_resource_checker"
  input_file       = "${path.module}/data/kubernetes_resource_checker.sh"
  md5              = filemd5("${path.module}/data/kubernetes_resource_checker.sh")
  description      = "Misconfiguration of Kubernetes resources such as incorrect CPU limit values or not enough resources allocated to the cluster."
  destination_path = "/agent/scripts/kubernetes_resource_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "increase_cpu_limits" {
  name             = "increase_cpu_limits"
  input_file       = "${path.module}/data/increase_cpu_limits.sh"
  md5              = filemd5("${path.module}/data/increase_cpu_limits.sh")
  description      = "Increase the CPU limits for the affected Kubernetes Pods: Insufficient CPU limits may cause this incident. Increasing the limits can help address the issue."
  destination_path = "/agent/scripts/increase_cpu_limits.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "increase_cpu_resources" {
  name             = "increase_cpu_resources"
  input_file       = "${path.module}/data/increase_cpu_resources.sh"
  md5              = filemd5("${path.module}/data/increase_cpu_resources.sh")
  description      = "Add more CPU resources to the Kubernetes cluster: If the cluster is already running at maximum capacity and the CPU limits are set appropriately, you may need to add more CPU resources to the cluster to avoid this incident."
  destination_path = "/agent/scripts/increase_cpu_resources.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cpu_limit_alert" {
  name        = "invoke_cpu_limit_alert"
  description = "Heavy load on the Kubernetes cluster which has caused the CPU usage to spike and exceed the limits set in place."
  command     = "`chmod +x /agent/scripts/cpu_limit_alert.sh && /agent/scripts/cpu_limit_alert.sh`"
  params      = ["DEPLOYMENT_NAME","NAMESPACE"]
  file_deps   = ["cpu_limit_alert"]
  enabled     = true
  depends_on  = [shoreline_file.cpu_limit_alert]
}

resource "shoreline_action" "invoke_kubernetes_resource_checker" {
  name        = "invoke_kubernetes_resource_checker"
  description = "Misconfiguration of Kubernetes resources such as incorrect CPU limit values or not enough resources allocated to the cluster."
  command     = "`chmod +x /agent/scripts/kubernetes_resource_checker.sh && /agent/scripts/kubernetes_resource_checker.sh`"
  params      = ["CONTAINER_NAME","NAMESPACE"]
  file_deps   = ["kubernetes_resource_checker"]
  enabled     = true
  depends_on  = [shoreline_file.kubernetes_resource_checker]
}

resource "shoreline_action" "invoke_increase_cpu_limits" {
  name        = "invoke_increase_cpu_limits"
  description = "Increase the CPU limits for the affected Kubernetes Pods: Insufficient CPU limits may cause this incident. Increasing the limits can help address the issue."
  command     = "`chmod +x /agent/scripts/increase_cpu_limits.sh && /agent/scripts/increase_cpu_limits.sh`"
  params      = ["SELECTOR_FOR_THE_AFFECTED_PODS","NAMESPACE"]
  file_deps   = ["increase_cpu_limits"]
  enabled     = true
  depends_on  = [shoreline_file.increase_cpu_limits]
}

resource "shoreline_action" "invoke_increase_cpu_resources" {
  name        = "invoke_increase_cpu_resources"
  description = "Add more CPU resources to the Kubernetes cluster: If the cluster is already running at maximum capacity and the CPU limits are set appropriately, you may need to add more CPU resources to the cluster to avoid this incident."
  command     = "`chmod +x /agent/scripts/increase_cpu_resources.sh && /agent/scripts/increase_cpu_resources.sh`"
  params      = ["NUMBER_OF_NODES_TO_ADD"]
  file_deps   = ["increase_cpu_resources"]
  enabled     = true
  depends_on  = [shoreline_file.increase_cpu_resources]
}

