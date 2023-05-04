resource "kubernetes_namespace" "aws-observability" {
  metadata {
    name = "aws-observability"
    labels = {
        aws-observability = "enabled"
    }
  }
  depends_on = [aws_eks_cluster.cluster]
}

resource "kubernetes_config_map" "aws-logging" {
  metadata {
    name = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
"output.conf" = <<EOF
[OUTPUT]
    Name cloudwatch_logs
    Match *
    region us-east-1
    log_group_name fluent-bit-cloudwatch
    log_stream_prefix from-fluent-bit-
    auto_create_group true
EOF
"filters.conf" = <<EOF
[FILTER]
    Name parser
    Match *
    Key_Name log
    Parser containerd
EOF
"parsers.conf" = <<EOF
[PARSER]
    Name         containerd
    Format       regex
    Regex        ^(?<time>[^ ]+) (?<stream>stdout|stderr|stdout) (?<logtag>[^ ]*) (?<log>.*)$
    Time_Key     time
    Time_Format  %Y-%m-%dT%H:%M:%S.%LZ
EOF
"flb_log_cw" = "true"
}
  depends_on = [kubernetes_namespace.aws-observability]
}