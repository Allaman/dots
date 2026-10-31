// Copy a token from the focused terminal's screen: URLs, paths, SHAs, UUIDs,
// IPs, k8s names and more get a letter hint; typing the hint copies it.
// Patterns follow rmarganti/herdr-pluck: a lower priority wins overlaps.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { hc, focused, notify, theme, settings, props, closeOverlay } from "herdr";

const ALPHABET = "asdfghjklqwertyuiopzxcvbnm";
const LINE = 20;

const K8S_KINDS = "deployment.app|binding|componentstatuse|configmap|endpoint|event|limitrange|namespace|node|persistentvolumeclaim|persistentvolume|pod|podtemplate|replicationcontroller|resourcequota|secret|serviceaccount|service|mutatingwebhookconfiguration.admissionregistration.k8s.io|validatingwebhookconfiguration.admissionregistration.k8s.io|customresourcedefinition.apiextension.k8s.io|apiservice.apiregistration.k8s.io|controllerrevision.apps|daemonset.apps|deployment.apps|replicaset.apps|statefulset.apps|tokenreview.authentication.k8s.io|localsubjectaccessreview.authorization.k8s.io|selfsubjectaccessreviews.authorization.k8s.io|selfsubjectrulesreview.authorization.k8s.io|subjectaccessreview.authorization.k8s.io|horizontalpodautoscaler.autoscaling|cronjob.batch|job.batch|certificatesigningrequest.certificates.k8s.io|events.events.k8s.io|daemonset.extensions|deployment.extensions|ingress.extensions|networkpolicies.extensions|podsecuritypolicies.extensions|replicaset.extensions|networkpolicie.networking.k8s.io|poddisruptionbudget.policy|clusterrolebinding.rbac.authorization.k8s.io|clusterrole.rbac.authorization.k8s.io|rolebinding.rbac.authorization.k8s.io|role.rbac.authorization.k8s.io|storageclasse.storage.k8s.io";

const PATTERNS = [
  ["url", 10, /((https?:\/\/|git@|git:\/\/|ssh:\/\/|ftp:\/\/|file:\/\/\/)[^\s()"']+)/g],
  ["git-status", 15, /(modified|deleted|deleted by us|new file): +(?<match>.+)/g],
  ["git-branch", 15, /Your branch is up to date with '(?<match>.*)'\./g],
  ["diff", 15, /(---|\+\+\+) [ab]\/(?<match>.*)/g],
  ["k8s", 18, new RegExp(`\\b(${K8S_KINDS})([/_#$%&+=@-][A-Za-z0-9_#$%&+=/@-]*)?\\b`, "g")],
  ["path", 20, /(([.\w\-~$@]+)?(\/[.\w\-@]+)+\/?)/g],
  ["uuid", 30, /\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b/g],
  ["k8s-pod", 35, /\b[a-z][a-z0-9-]*[a-z0-9]-[bcdfghjklmnpqrstvwxz2456789]{5,10}-[bcdfghjklmnpqrstvwxz2456789]{5}\b/g],
  ["sha", 40, /\b[0-9a-fA-F]{7,40}\b/g],
  ["hex", 45, /\b0x[0-9a-fA-F]+\b/g],
  ["ipv4", 50, /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/g],
  ["number", 60, /[0-9]{4,}/g],
];

function tokens(text) {
  const found = [];
  text.split("\n").forEach((line, row) => {
    for (const [kind, priority, re] of PATTERNS) {
      for (const m of line.matchAll(re)) {
        const value = m.groups?.match ?? m[0];
        const start = m.index + m[0].indexOf(value);
        found.push({ kind, priority, row, start, end: start + value.length, value: value.trim() });
      }
    }
  });
  found.sort((a, b) => a.priority - b.priority || b.end - b.start - (a.end - a.start));
  const kept = [];
  for (const f of found) {
    if (f.value && !kept.some((k) => k.row === f.row && f.start < k.end && k.start < f.end)) kept.push(f);
  }
  // Newest output (bottom of the screen) gets the first hints; repeats share one.
  kept.sort((a, b) => b.row - a.row || a.start - b.start);
  const values = [...new Set(kept.map((k) => k.value))];
  const keys = hints(values.length);
  const hintOf = new Map(values.map((v, i) => [v, keys[i]]));
  return kept.map((k) => ({ ...k, hint: hintOf.get(k.value) }));
}

function hints(n) {
  if (n <= ALPHABET.length) return [...ALPHABET].slice(0, n);
  return [...ALPHABET].flatMap((a) => [...ALPHABET].map((b) => a + b)).slice(0, n);
}

export default class Pluck extends View {
  init(_props, cx) {
    this.items = null;
    this.error = null;
    this.typed = "";
    this.handle = cx.focus_handle();
    this.handle.focus();
    const terminal = focused()?.terminal;
    cx.spawn(async (cx) => {
      if (!terminal) this.error = "No terminal focused";
      else {
        const r = await hc(["read", "--json", terminal]);
        if (r.code !== 0) this.error = r.stderr.trim() || `hc read exited with ${r.code}`;
        else {
          const lines = (JSON.parse(r.stdout).text ?? "").split("\n");
          while (lines.length && !lines.at(-1).trim()) lines.pop();
          this.lines = lines;
          this.items = tokens(lines.join("\n"));
        }
      }
      cx.notify();
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  render() {
    const t = theme();
    const items = this.items ?? [];
    const dim = (item) => this.typed && !item.hint.startsWith(this.typed);

    // The screen as the terminal shows it; each hint covers the start of its token.
    const line = (text, row) => {
      const parts = [];
      let at = 0;
      for (const item of items.filter((i) => i.row === row).sort((a, b) => a.start - b.start)) {
        if (item.start > at) parts.push(div().child(text.slice(at, item.start)));
        const shown = text.slice(item.start, item.end);
        parts.push(
          h_flex()
            .when(dim(item), (el) => el.opacity(0.3))
            .child(div().bg(t.accent).text_color(t.background).font_bold().child(item.hint))
            .child(div().text_color(t.accent).underline().child(shown.slice(item.hint.length))),
        );
        at = item.end;
      }
      if (at < text.length) parts.push(div().child(text.slice(at)));
      return h_flex().h(LINE).flex_none().whitespace_nowrap().overflow_hidden().children(parts);
    };

    const empty = (text) => div().px(14).py(8).text_color(t.dim).child(text);
    const body = this.error ? [empty(this.error)] : this.items === null ? [empty("Reading screen…")] : items.length ? this.lines.map(line) : [empty("Nothing to pluck")];

    return v_flex()
      .id("pluck")
      .track_focus(this.handle)
      .size_full()
      .min_h(0)
      .p(18)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        const k = e.key;
        if (k === "escape" || (k === "c" && e.modifiers.control)) return this.close();
        if (k === "backspace") this.typed = this.typed.slice(0, -1);
        else if (k.length === 1 && ALPHABET.includes(k) && !e.modifiers.control && !e.modifiers.platform) {
          const typed = this.typed + k;
          const hit = items.find((i) => i.hint === typed);
          if (hit) {
            cx.write_to_clipboard(hit.value);
            notify({ title: "Copied", body: hit.value });
            return this.close();
          }
          this.typed = items.some((i) => i.hint.startsWith(typed)) ? typed : "";
        } else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child("Pluck")).child(div().text_size(11).text_color(t.dim).child("Type a hint to copy · Esc")))
      .child(v_flex().id("pluck-screen").flex_1().min_h(0).overflow_y_scrollbar().font_family(settings().font_family ?? "JetBrains Mono").text_size(13).text_color(t.muted).children(body));
  }
}
