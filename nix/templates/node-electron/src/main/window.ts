import type { BrowserWindowConstructorOptions } from "electron";

// Security baseline: https://www.electronjs.org/docs/latest/tutorial/security
export function windowOptions(
  preloadPath: string,
): BrowserWindowConstructorOptions {
  return {
    width: 900,
    height: 670,
    show: false,
    autoHideMenuBar: true,
    webPreferences: {
      preload: preloadPath,
      contextIsolation: true,
      sandbox: true,
      nodeIntegration: false,
      webSecurity: true,
    },
  };
}
