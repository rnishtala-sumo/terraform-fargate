resource "aws_efs_file_system" "eks" {
  creation_token = "eks"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  # lifecycle_policy {
  #   transition_to_ia = "AFTER_30_DAYS"
  # }

  tags = {
    Name = "eks"
  }
}

resource "aws_efs_mount_target" "zone-a" {
  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = aws_subnet.private-us-east-1a.id
  security_groups = [aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
}

resource "aws_efs_mount_target" "zone-b" {
  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = aws_subnet.private-us-east-1b.id
  security_groups = [aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
}

data "external" "create_access_points_logs" {
  program = ["python3", "create-access-points-logs.py"]
  query = {
    AWS_REGION = "us-east-1"
    HELM_INSTALLATION_NAME = "sumo"
    NUMBER_PODS = 3
    EFS_ID = aws_efs_file_system.eks.id
    NAMESPACE = "staging"
  }
  depends_on = [aws_efs_file_system.eks]
}

output "create_access_points_logs" {
  value       = data.external.create_access_points_logs.result
  description = "create_access_points_logs"
}

data "external" "create_access_points_metrics" {
  program = ["python3", "create-access-points-metrics.py"]
  query = {
    AWS_REGION = "us-east-1"
    HELM_INSTALLATION_NAME = "sumo"
    NUMBER_PODS = 3
    EFS_ID = aws_efs_file_system.eks.id
    NAMESPACE = "staging"
  }
  depends_on = [aws_efs_file_system.eks]
}

output "create_access_points_metrics" {
  value       = data.external.create_access_points_metrics.result
  description = "create_access_points_metrics"
}

data "external" "create_access_points_events" {
  program = ["python3", "create-access-points-events.py"]
  query = {
    AWS_REGION = "us-east-1"
    HELM_INSTALLATION_NAME = "sumo"
    NUMBER_PODS = 1
    EFS_ID = aws_efs_file_system.eks.id
    NAMESPACE = "staging"
  }
  depends_on = [aws_efs_file_system.eks]
}

output "create_access_points_events" {
  value       = data.external.create_access_points_events.result
  description = "create_access_points_events"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "kubernetes_storage_class" "efs-sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  volume_binding_mode = "Immediate"
}

resource "kubernetes_persistent_volume" "file-storage-sumo-sumologic-otelcol-logs-0" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-logs-0"
    labels = {
      app = "file-storage-sumo-sumologic-otelcol-logs-0"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    storage_class_name = "efs-sc"
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${aws_efs_file_system.eks.id}::${data.external.create_access_points_logs.result.fsap0}"
      }
    }
  }
  depends_on = [data.external.create_access_points_logs]
}

resource "kubernetes_persistent_volume_claim" "file-storage-sumo-sumologic-otelcol-logs-0" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-logs-0"
    namespace = "staging"
  }
  spec {
    storage_class_name = "efs-sc"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-logs-0.metadata.0.name}"
  }
  depends_on = [kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-logs-0]
}

resource "kubernetes_persistent_volume" "file-storage-sumo-sumologic-otelcol-logs-1" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-logs-1"
    labels = {
      app = "file-storage-sumo-sumologic-otelcol-logs-1"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    storage_class_name = "efs-sc"
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${aws_efs_file_system.eks.id}::${data.external.create_access_points_logs.result.fsap1}"
      }
    }
  }
  depends_on = [data.external.create_access_points_logs]
}

resource "kubernetes_persistent_volume_claim" "file-storage-sumo-sumologic-otelcol-logs-1" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-logs-1"
    namespace = "staging"
  }
  spec {
    storage_class_name = "efs-sc"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-logs-1.metadata.0.name}"
  }
  depends_on = [kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-logs-1]
}

resource "kubernetes_persistent_volume" "file-storage-sumo-sumologic-otelcol-logs-2" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-logs-2"
    labels = {
      app = "file-storage-sumo-sumologic-otelcol-logs-2"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    storage_class_name = "efs-sc"
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${aws_efs_file_system.eks.id}::${data.external.create_access_points_logs.result.fsap2}"
      }
    }
  }
  depends_on = [data.external.create_access_points_logs]
}

resource "kubernetes_persistent_volume_claim" "file-storage-sumo-sumologic-otelcol-logs-2" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-logs-2"
    namespace = "staging"
  }
  spec {
    storage_class_name = "efs-sc"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-logs-2.metadata.0.name}"
  }
  depends_on = [kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-logs-2]
}

resource "kubernetes_persistent_volume" "file-storage-sumo-sumologic-otelcol-metrics-0" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-metrics-0"
    labels = {
      app = "file-storage-sumo-sumologic-otelcol-metrics-0"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    storage_class_name = "efs-sc"
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${aws_efs_file_system.eks.id}::${data.external.create_access_points_metrics.result.fsap0}"
      }
    }
  }
  depends_on = [data.external.create_access_points_metrics]
}

resource "kubernetes_persistent_volume_claim" "file-storage-sumo-sumologic-otelcol-metrics-0" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-metrics-0"
    namespace = "staging"
  }
  spec {
    storage_class_name = "efs-sc"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-metrics-0.metadata.0.name}"
  }
  depends_on = [kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-metrics-0]
}

resource "kubernetes_persistent_volume" "file-storage-sumo-sumologic-otelcol-metrics-1" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-metrics-1"
    labels = {
      app = "file-storage-sumo-sumologic-otelcol-metrics-1"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    storage_class_name = "efs-sc"
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${aws_efs_file_system.eks.id}::${data.external.create_access_points_metrics.result.fsap1}"
      }
    }
  }
  depends_on = [data.external.create_access_points_metrics]
}

resource "kubernetes_persistent_volume_claim" "file-storage-sumo-sumologic-otelcol-metrics-1" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-metrics-1"
    namespace = "staging"
  }
  spec {
    storage_class_name = "efs-sc"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-metrics-1.metadata.0.name}"
  }
  depends_on = [kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-metrics-1]
}

resource "kubernetes_persistent_volume" "file-storage-sumo-sumologic-otelcol-metrics-2" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-metrics-2"
    labels = {
      app = "file-storage-sumo-sumologic-otelcol-metrics-2"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    storage_class_name = "efs-sc"
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${aws_efs_file_system.eks.id}::${data.external.create_access_points_metrics.result.fsap2}"
      }
    }
  }
  depends_on = [data.external.create_access_points_metrics]
}

resource "kubernetes_persistent_volume_claim" "file-storage-sumo-sumologic-otelcol-metrics-2" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-metrics-2"
    namespace = "staging"
  }
  spec {
    storage_class_name = "efs-sc"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-metrics-2.metadata.0.name}"
  }
  depends_on = [kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-metrics-2]
}

resource "kubernetes_persistent_volume" "file-storage-sumo-sumologic-otelcol-events-0" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-events-0"
    labels = {
      app = "file-storage-sumo-sumologic-otelcol-events-0"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    storage_class_name = "efs-sc"
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${aws_efs_file_system.eks.id}::${data.external.create_access_points_events.result.fsap0}"
      }
    }
  }
  depends_on = [data.external.create_access_points_events]
}

resource "kubernetes_persistent_volume_claim" "file-storage-sumo-sumologic-otelcol-events-0" {
  metadata {
    name = "file-storage-sumo-sumologic-otelcol-events-0"
    namespace = "staging"
  }
  spec {
    storage_class_name = "efs-sc"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-events-0.metadata.0.name}"
  }
  depends_on = [kubernetes_persistent_volume.file-storage-sumo-sumologic-otelcol-events-0]
}