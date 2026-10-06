import { contextBridge, ipcRenderer } from "electron";
import { type AppApi, IpcChannel } from "../shared/api";

// Expose a narrow, typed API instead of ipcRenderer itself.
const api: AppApi = {
  getVersion: () => ipcRenderer.invoke(IpcChannel.AppVersion),
};

contextBridge.exposeInMainWorld("api", api);
