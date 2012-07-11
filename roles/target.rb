name "target"
description "Used for tagging which boxes are targets"
run_list("recipe[knife-workstation::ubuntu-user]","recipe[knife-workstation::ssh]")
