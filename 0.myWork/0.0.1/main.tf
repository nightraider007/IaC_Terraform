resource "random_string" "prefix" {
  count  = 3
  length = 50
  # Use the fullname local variable to generate a unique name

}

