data "aws_iam_policy_document" "aws_cloudwatch_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:sumo-sumologic-otelcol-logs-collector"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cloudwatch_access_role" {
  assume_role_policy = data.aws_iam_policy_document.aws_cloudwatch_assume_role_policy.json
  name               = "cloudwatch-role"
}

resource "aws_iam_policy" "policy" {
  name        = "cloudwatch-policy"
  description = "A fargate policy"
  policy      = "${file("fargate-policy.json")}"
}

resource "aws_iam_policy_attachment" "cloudwatch-attach" {
  name       = "cloudwatch-attachment"
  roles      = ["${aws_iam_role.cloudwatch_access_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name  = "cloudwatch_profile"
  role = "${aws_iam_role.cloudwatch_access_role.name}"
}