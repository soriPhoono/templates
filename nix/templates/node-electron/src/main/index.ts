import { join } from "node:path";
import { app, BrowserWindow, ipcMain, shell } from "electron";
import { IpcChannel } from "../shared/api";
import { windowOptions } from "./window";

function createWindow(): void {
  const window = new BrowserWindow(
    windowOptions(join(__dirname, "../preload/index.js")),
  );

  window.once("ready-to-show", () => window.show());

  // Open external links in the system browser, never in the app.
  window.webContents.setWindowOpenHandler(({ url }) => {
    void shell.openExternal(url);
    return { action: "deny" };
  });

  const devServerUrl = process.env.ELECTRON_RENDERER_URL;
  if (!app.isPackaged && devServerUrl) {
    void window.loadURL(devServerUrl);
  } else {
    void window.loadFile(join(__dirname, "../renderer/index.html"));
  }
}

app.whenReady().then(() => {
  ipcMain.handle(IpcChannel.AppVersion, () => app.getVersion());

  createWindow();

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
