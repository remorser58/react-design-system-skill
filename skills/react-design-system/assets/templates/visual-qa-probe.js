// Browser-runnable Visual QA probe for Desktop, Tablet, and Mobile viewports.
// Execute via browser devtools/evaluate on each viewport + theme (light/dark).
(() => {
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  const sw = document.documentElement.scrollWidth;
  const isCoarse = window.matchMedia("(pointer: coarse)").matches;
  const viewportMeta = document.querySelector('meta[name="viewport"]')?.getAttribute("content") ?? "";

  const isVisible = (el) => {
    const s = getComputedStyle(el);
    if (s.display === "none" || s.visibility === "hidden" || parseFloat(s.opacity) === 0) return false;
    const r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  };

  const coarseTouchTargetFailures = [];
  if (isCoarse) {
    for (const el of document.querySelectorAll('a,button,input,select,textarea,[role="button"],[role="tab"],[role="switch"],[role="checkbox"]')) {
      if (!isVisible(el)) continue;
      const r = el.getBoundingClientRect();
      const afterStyle = getComputedStyle(el, "::after");
      const hasTouchSlop = el.classList.contains("touch-slop") && afterStyle.content !== "none";
      if (!hasTouchSlop && (r.width < 44 || r.height < 44)) {
        coarseTouchTargetFailures.push({
          tag: el.tagName.toLowerCase(),
          text: (el.textContent || el.getAttribute("aria-label") || "").trim().slice(0, 40),
          width: Math.round(r.width),
          height: Math.round(r.height),
        });
      }
    }
  }

  const coarseInputFontFailures = [];
  if (isCoarse) {
    for (const el of document.querySelectorAll("input,textarea,select")) {
      if (!isVisible(el)) continue;
      const fs = parseFloat(getComputedStyle(el).fontSize);
      if (fs < 16) {
        coarseInputFontFailures.push({ tag: el.tagName.toLowerCase(), fontSize: fs });
      }
    }
  }

  const nonOverlayShadowHits = [];
  for (const el of document.querySelectorAll("*")) {
    if (!isVisible(el)) continue;
    const s = getComputedStyle(el);
    if (s.boxShadow === "none") continue;
    const role = el.getAttribute("role") || "";
    const inOverlay = Boolean(el.closest('[role="dialog"],[role="menu"],[role="listbox"],[data-floating]')) || role === "dialog" || role === "menu";
    const isVeil = el.classList.contains("veil-field") || el.classList.contains("veil-overlay");
    if (!inOverlay && !isVeil) {
      nonOverlayShadowHits.push({
        tag: el.tagName.toLowerCase(),
        className: String(el.className || "").slice(0, 60),
        boxShadow: s.boxShadow.slice(0, 60),
      });
    }
  }

  const missingAltImages = Array.from(document.querySelectorAll("img"))
    .filter((img) => isVisible(img) && !img.hasAttribute("alt"))
    .map((img) => img.getAttribute("src") || "(no-src)");

  const unnamedButtons = Array.from(document.querySelectorAll("button,[role='button']"))
    .filter((b) => isVisible(b) && !(b.textContent || "").trim() && !b.getAttribute("aria-label") && !b.getAttribute("aria-labelledby"))
    .map((b) => b.outerHTML.slice(0, 80));

  const horizontalOverflow = sw > vw;
  const viewportFitCover = viewportMeta.includes("viewport-fit=cover");
  const zoomLockViolation = /user-scalable\s*=\s*no|maximum-scale\s*=\s*1(\b|$)/i.test(viewportMeta);

  const ok =
    !horizontalOverflow &&
    viewportFitCover &&
    !zoomLockViolation &&
    coarseTouchTargetFailures.length === 0 &&
    coarseInputFontFailures.length === 0 &&
    nonOverlayShadowHits.length === 0 &&
    missingAltImages.length === 0 &&
    unnamedButtons.length === 0;

  return {
    ok,
    viewport: { width: vw, height: vh, scrollWidth: sw, isCoarse },
    horizontalOverflow,
    viewportFitCover,
    zoomLockViolation,
    coarseTouchTargetFailures: coarseTouchTargetFailures.slice(0, 15),
    coarseInputFontFailures: coarseInputFontFailures.slice(0, 15),
    nonOverlayShadowHits: nonOverlayShadowHits.slice(0, 15),
    missingAltImages: missingAltImages.slice(0, 15),
    unnamedButtons: unnamedButtons.slice(0, 15),
  };
})();
