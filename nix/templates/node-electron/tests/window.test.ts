import { describe, expect, it } from "vitest";
import { windowOptions } from "../src/main/window";

describe("windowOptions", () => {
  const { webPreferences } = windowOptions("/preload.js");

  it("wires the preload script", () => {
    expect(webPreferences?.preload).toBe("/preload.js");
  });

  it("keeps the renderer isolated and sandboxed", () => {
    expect(webPreferences).toMatchObject({
      contextIsolation: true,
      sandbox: true,
      nodeIntegration: false,
      webSecurity: true,
    });
  });
});
