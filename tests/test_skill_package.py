"""Offline verification tests for the react-design-system skill repository."""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
SKILL = REPO / "skills" / "react-design-system"


class SkillPackageTests(unittest.TestCase):
    def test_required_files_and_bilingual_pairs_exist(self):
        self.assertTrue((SKILL / "SKILL.md").is_file())
        self.assertTrue((SKILL / "SKILL.ko.md").is_file())
        self.assertTrue((SKILL / "scripts" / "audit-react-ds.sh").is_file())
        self.assertTrue((SKILL / "assets" / "evals" / "react-design-system-cases.jsonl").is_file())
        for folder in ("rules", "references"):
            en_files = sorted(p for p in (SKILL / folder).glob("*.md") if not p.name.endswith(".ko.md"))
            self.assertTrue(en_files, folder)
            for en_path in en_files:
                ko_path = en_path.with_name(f"{en_path.stem}.ko.md")
                self.assertTrue(ko_path.is_file(), f"Missing Korean sibling for {en_path.name}")

    def test_frontmatter_and_tag_parity(self):
        for filename in ("SKILL.md", "SKILL.ko.md"):
            text = (SKILL / filename).read_text(encoding="utf-8")
            self.assertTrue(text.startswith("---\n"), filename)
            self.assertIn('name: "react-design-system"', text, filename)
        en_tags = re.findall(r"^<(/?[a-z_]+)>$", (SKILL / "SKILL.md").read_text(encoding="utf-8"), flags=re.M)
        ko_tags = re.findall(r"^<(/?[a-z_]+)>$", (SKILL / "SKILL.ko.md").read_text(encoding="utf-8"), flags=re.M)
        self.assertEqual(en_tags, ko_tags)

    def test_code_fences_are_balanced(self):
        for path in sorted(SKILL.rglob("*.md")):
            fences = [line for line in path.read_text(encoding="utf-8").splitlines() if line.lstrip().startswith(("```", "~~~"))]
            self.assertEqual(len(fences) % 2, 0, f"Unbalanced fences in {path.relative_to(SKILL)}")

    def test_eval_jsonl_has_20_cases_and_required_categories(self):
        lines = [line for line in (SKILL / "assets" / "evals" / "react-design-system-cases.jsonl").read_text(encoding="utf-8").splitlines() if line.strip()]
        self.assertEqual(len(lines), 20)
        categories = set()
        languages = set()
        for line in lines:
            row = json.loads(line)
            categories.add(row["category"])
            languages.add(row["language"])
            if row["category"] in {"positive", "negative", "boundary", "coexistence"}:
                self.assertIn(row["expect"], {"trigger", "no_trigger"})
                self.assertGreaterEqual(row["runs"], 1)
                self.assertGreater(row["threshold"], 0)
                self.assertLess(row["threshold"], 1)
        self.assertEqual(categories, {"positive", "negative", "boundary", "workflow", "source", "safety", "adversarial", "regression", "coexistence"})
        self.assertEqual(languages, {"en", "ko", "mixed"})

    def test_audit_script_syntax_and_strict_detection(self):
        script = SKILL / "scripts" / "audit-react-ds.sh"
        syntax = subprocess.run(["bash", "-n", str(script)], capture_output=True, text=True)
        self.assertEqual(syntax.returncode, 0, syntax.stderr)
        if not shutil.which("jq"):
            self.skipTest("jq not available")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            clean = root / "clean"
            (clean / "src" / "design-system" / "motion").mkdir(parents=True)
            (clean / "src" / "design-system" / "patterns").mkdir(parents=True)
            (clean / "src" / "design-system" / "stories").mkdir(parents=True)
            (clean / ".storybook").mkdir()
            shutil.copy2(SKILL / "assets" / "templates" / "index.html", clean / "index.html")
            shutil.copy2(SKILL / "assets" / "templates" / "glass-and-motion.css", clean / "src" / "design-system" / "motion" / "motion.css")
            (clean / "src" / "design-system" / "patterns" / "skeleton.tsx").write_text("export function Skeleton(){return <div className='min-h-dvh' />}\n", encoding="utf-8")
            (clean / "src" / "design-system" / "stories" / "button.stories.tsx").write_text("export default { title: 'Button' };\n", encoding="utf-8")
            (clean / "package.json").write_text(json.dumps({
                "dependencies": {
                    "react": "19", "@base-ui/react": "1", "motion": "12",
                    "@tanstack/react-query": "5", "@tanstack/react-router": "1",
                    "@tanstack/react-table": "8", "zustand": "5", "ky": "1"
                },
                "devDependencies": {"vite": "6", "@storybook/react-vite": "9"}
            }), encoding="utf-8")
            clean_res = subprocess.run(["bash", str(script), "--root", str(clean), "--strict", "--json"], capture_output=True, text=True)
            self.assertEqual(clean_res.returncode, 0, clean_res.stderr)
            clean_data = json.loads(clean_res.stdout)
            self.assertTrue(clean_data["ok"])
            self.assertEqual(clean_data["summary"]["errors"], 0)

            dirty = root / "dirty"
            (dirty / "src").mkdir(parents=True)
            (dirty / "index.html").write_text('<meta name="viewport" content="width=device-width, maximum-scale=1, user-scalable=no">', encoding="utf-8")
            (dirty / "package.json").write_text('{"dependencies":{"react":"19","@radix-ui/react-dialog":"1"}}', encoding="utf-8")
            (dirty / "src" / "Bad.tsx").write_text('export function Bad(){ useEffect(() => { fetch("/api"); }, []); return <Card className="shadow-lg h-screen"><GlassView style={{ opacity: 0 }} /></Card>; }\n', encoding="utf-8")
            dirty_res = subprocess.run(["bash", str(script), "--root", str(dirty), "--strict", "--json"], capture_output=True, text=True)
            self.assertEqual(dirty_res.returncode, 0, dirty_res.stderr)
            dirty_data = json.loads(dirty_res.stdout)
            self.assertFalse(dirty_data["ok"])
            codes = {v["code"] for v in dirty_data["violations"]}
            for expected_code in ("HEAD_ZOOM_LOCK", "SURFACE_SHADOW_UTILITY", "SURFACE_CARD_SOUP", "GLASS_OPACITY_ZERO", "STACK_FORBIDDEN_UI_KIT", "PERF_EFFECT_FETCH_WATERFALL"):
                self.assertIn(expected_code, codes)

    def test_version_files_and_plugin_manifests_are_synchronized(self):
        version_text = (REPO / "VERSION").read_text(encoding="utf-8").strip()
        self.assertRegex(version_text, r"^\d+\.\d+\.\d+$")
        plugin = json.loads((REPO / ".claude-plugin" / "plugin.json").read_text(encoding="utf-8"))
        marketplace = json.loads((REPO / ".claude-plugin" / "marketplace.json").read_text(encoding="utf-8"))
        self.assertEqual(plugin["version"], version_text)
        self.assertEqual(marketplace["plugins"][0]["version"], version_text)


if __name__ == "__main__":
    unittest.main()
