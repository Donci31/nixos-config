$env.STARSHIP_LOG = "error"
$env.STARSHIP_CONFIG = "/home/hadoop/.config/starship.toml"

$env.config = ($env.config? | default {})
$env.config.edit_mode = "vi"
$env.config.show_banner = false
$env.config.history.file_format = "sqlite"

# Auto-generate Starship prompt into autoload vendor directory
let starship_nu = ($nu.data-dir | path join "vendor/autoload/starship.nu")
if not ($starship_nu | path exists) {
  mkdir ($nu.data-dir | path join "vendor/autoload")
  starship init nu | save -f $starship_nu
}

# Auto-generate Zoxide & Carapace into autoload vendor directory
let zoxide_nu = ($nu.data-dir | path join "vendor/autoload/zoxide.nu")
if not ($zoxide_nu | path exists) and (which zoxide | is-not-empty) {
  zoxide init nushell | save -f $zoxide_nu
}

let carapace_nu = ($nu.data-dir | path join "vendor/autoload/carapace.nu")
if not ($carapace_nu | path exists) and (which carapace | is-not-empty) {
  carapace _carapace nushell | save -f $carapace_nu
}
