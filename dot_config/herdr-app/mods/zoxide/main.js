// Open a zoxide directory: Enter as a new space, ctrl+t as a tab, ctrl+s as a
// split to the right. Every space-separated word must appear in the path.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, run, theme, home, props, closeOverlay } from "herdr";

const SHOWN = 100;
const ROW = 32;

const basename = (dir) => dir.split("/").filter(Boolean).pop() ?? dir;

export default class Zoxide extends View {
  init(_props, cx) {
    this.dirs = null;
    this.error = null;
    this.filter = "";
    this.at = 0;
    this.input = InputState.new({ placeholder: "Find a directory…" });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value(); this.at = 0; cx.notify(); });
    this.input.on("submit", () => this.open(this.matches()[this.at], "space"));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
    cx.spawn(async (cx) => {
      try {
        // Herdr doesn't source ~/.shell/tools, so pass its zoxide database along.
        const r = await exec("env", [`_ZO_DATA_DIR=${home()}/data/.zoxide`, "zoxide", "query", "-l"]);
        if (r.code === 0) this.dirs = r.stdout.split("\n").filter(Boolean);
        else this.error = r.stderr.trim() || `zoxide exited with ${r.code}`;
      } catch (e) {
        this.error = `zoxide: ${e}`;
      }
      cx.notify();
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  matches() {
    const words = this.filter.toLowerCase().split(/\s+/).filter(Boolean);
    return (this.dirs ?? []).filter((d) => words.every((w) => d.toLowerCase().includes(w))).slice(0, SHOWN);
  }

  open(dir, as) {
    if (!dir) return;
    this.close();
    const name = basename(dir);
    if (as === "space") run("space.new", { name, folder: dir });
    else if (as === "tab") run("tab.new", { name, folder: dir });
    else run("terminal.open", { folder: dir, place: "right" });
  }

  render() {
    const t = theme();
    const list = this.matches();
    this.at = Math.max(0, Math.min(this.at, list.length - 1));
    const h = home();
    const short = (d) => (d.startsWith(h) ? "~" + d.slice(h.length) : d);

    const row = (dir, i) =>
      h_flex()
        .id(`zx-${i}`)
        .mx(4)
        .px(10)
        .h(ROW)
        .flex_none()
        .rounded(7)
        .gap(10)
        .items_center()
        .cursor_pointer()
        .when(i === this.at, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.open(dir, "space"))
        .child(div().flex_none().text_color(t.foreground).font_semibold().child(basename(dir)))
        .child(div().flex_1().truncate().text_size(11).text_color(t.dim).child(short(dir)));

    const empty = (text) => div().px(14).py(8).text_color(t.dim).child(text);
    const body = this.error ? [empty(this.error)] : this.dirs === null ? [empty("Loading…")] : list.length ? list.map(row) : [empty("No match")];

    return v_flex()
      .id("zoxide")
      .track_focus(this.handle)
      .w_full()
      .min_h(0)
      .p(18)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const k = e.key;
        if (k === "escape") return this.close();
        if (k === "down") this.at = Math.min(this.at + 1, list.length - 1);
        else if (k === "up") this.at = Math.max(this.at - 1, 0);
        else if (k === "t" && e.modifiers.control) return this.open(list[this.at], "tab");
        else if (k === "s" && e.modifiers.control) return this.open(list[this.at], "split");
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child("Zoxide")).child(div().text_size(11).text_color(t.dim).child("Enter space · ^T tab · ^S split · Esc")))
      .child(
        h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(9).border_1().border_color(t.accent).bg(t.background)
          .child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))
          .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
      )
      .child(v_flex().h(Math.min(400, 6 + body.length * ROW)).min_h(0).flex_shrink(1).pb(6).overflow_y_scrollbar().children(body));
  }
}
