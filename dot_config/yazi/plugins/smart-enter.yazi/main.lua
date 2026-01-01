--- @sync entry
return {
  entry = function(_, job)
    local h = cx.active.current.hovered
    ya.mgr_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
  end,
}
