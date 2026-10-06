// Contract shared by main, preload and renderer. Every IPC channel the
// renderer can reach is listed here and exposed through the preload bridge.
export const IpcChannel = {
  AppVersion: "app:version",
} as const;

export interface AppApi {
  getVersion(): Promise<string>;
}
