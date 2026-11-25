import type { Preview } from "@storybook/react-vite";
import { MotionConfig } from "motion/react";
import { useEffect } from "react";
import "../src/design-system/motion/motion.css";

const VIEWPORTS = {
  mobile320: { name: "Mobile 320", styles: { width: "320px", height: "568px" } },
  mobile375: { name: "Mobile 375", styles: { width: "375px", height: "812px" } },
  tablet768: { name: "Tablet 768", styles: { width: "768px", height: "1024px" } },
  tablet1024: { name: "Tablet 1024", styles: { width: "1024px", height: "768px" } },
  desktop1280: { name: "Desktop 1280", styles: { width: "1280px", height: "800px" } },
  desktop1440: { name: "Desktop 1440", styles: { width: "1440px", height: "900px" } },
};

const preview: Preview = {
  globalTypes: {
    theme: {
      description: "Color theme",
      toolbar: {
        title: "Theme",
        items: [
          { value: "light", title: "Light" },
          { value: "dark", title: "Dark" },
        ],
        dynamicTitle: true,
      },
    },
    platform: {
      description: "Typography platform board",
      toolbar: {
        title: "Platform",
        items: [
          { value: "web", title: "Web" },
          { value: "desktop", title: "Desktop" },
          { value: "mobile", title: "Mobile" },
        ],
        dynamicTitle: true,
      },
    },
  },
  initialGlobals: {
    theme: "light",
    platform: "web",
  },
  parameters: {
    viewport: { options: VIEWPORTS },
    a11y: { test: "error" },
    layout: "padded",
  },
  decorators: [
    (Story, context) => {
      const theme = context.globals.theme ?? "light";
      const platform = context.globals.platform ?? "web";

      useEffect(() => {
        const root = document.documentElement;
        root.classList.toggle("dark", theme === "dark");
        root.setAttribute("data-platform", platform);
      }, [theme, platform]);

      return (
        <MotionConfig reducedMotion="user">
          <div className="min-h-dvh bg-bg-default text-text-primary">
            <Story />
          </div>
        </MotionConfig>
      );
    },
  ],
};

export default preview;
