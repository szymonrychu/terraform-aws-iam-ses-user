provider "aws" {
  alias  = "aws_ses"
  region = var.ses_region
}

resource "aws_iam_user" "this" {
  provider = aws.aws_ses
  count    = var.enabled ? 1 : 0

  name                 = var.user_name
  path                 = var.path
  permissions_boundary = var.permissions_boundary
  force_destroy        = var.force_destroy
  tags                 = var.tags
}

resource "aws_iam_access_key" "this" {
  provider = aws.aws_ses
  count    = var.enabled ? 1 : 0

  user    = aws_iam_user.this[0].name
  pgp_key = var.pgp_key
}

data "aws_iam_policy_document" "ses_send_access" {
  statement {
    effect = "Allow"

    actions = [
      "ses:SendRawEmail",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "this" {
  provider = aws.aws_ses
  count    = var.enabled ? 1 : 0

  name_prefix = var.user_policy_name_prefix
  user        = aws_iam_user.this[0].name

  policy = data.aws_iam_policy_document.ses_send_access.json
}
