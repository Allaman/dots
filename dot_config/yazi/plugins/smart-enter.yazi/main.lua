--- @sync entry
return {
  entry = function(_, job)
    local h = cx.active.current.hovered
    ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
  end,
}
