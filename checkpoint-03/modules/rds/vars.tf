#DB da SG
resource "aws_db_subnet_group" "db_sn_group" {
    name    = "db_sn_group"
    subnet_ids = ["${var.sn_priv_1a_id}", "${var.sn_priv_1c.id}"]

    tags = {
        Name = "db_sn_group"
    }
}

# Parameter Groups

