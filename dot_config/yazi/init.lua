-- This plugin provides cross-instance yank ability,which means you can yank files in one instance, and then paste them in another instance.
-- https://yazi-rs.github.io/docs/dds#session.lua
require("session"):setup({
  sync_yanked = true,
})
-- zoxide now supports the new update_db feature, which automatically adds Yazi's CWD to zoxide when navigating.
require("zoxide"):setup({
  update_db = true,
})

th.git = th.git or {}
th.git.unknown_sign = " "
th.git.modified_sign = "M"
th.git.deleted_sign = "D"
th.git.added_sign = "A"
th.git.untracked_sign = "U"
-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("git"):setup({
  order = 1500,
})
