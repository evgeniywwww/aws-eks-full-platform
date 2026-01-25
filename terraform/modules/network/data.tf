# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

# This data source asks AWS:
# "Which availability zones are currently available in this region?"
#
# Important:
# - This is raw data from AWS.
# - No decisions are made here.
# - We just get a list of AZ names like:
#   ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
#

data "aws_availability_zones" "available" {
  state = "available"
}