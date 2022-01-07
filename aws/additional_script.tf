data "local_file" "additional_scripts" {
  count    = length(var.additional_script_files)
  filename = var.additional_script_files[count.index]
}
