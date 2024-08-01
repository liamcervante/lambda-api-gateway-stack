provider "aws" {
  region = "eu-central-1"
}

resource "aws_iam_openid_connect_provider" "default" {
  url = "https://app.terraform.io"
  client_id_list = [
    "aws.workload.identity",
  ]
  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]
}

resource "aws_iam_role" "default" {
  name               = "lambda-api-gateway-stack"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }
    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:org-bG8tiTdMQAnQd7do:*"]
    }
  }
}

// These are super overkill, but they just let me do whatever I want in my stacks.

resource "aws_iam_role_policy_attachment" "iam" {
    role = aws_iam_role.default.name
    policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "sudo" {
    role = aws_iam_role.default.name
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

output "role_arn" {
    value = aws_iam_role.default.arn
}
