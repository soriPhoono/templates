import type { Server } from "node:http";
import type { AddressInfo } from "node:net";
import { createApp } from "./app.ts";
import type { Config } from "./config.ts";

export interface RunningServer {
  port: number;
  close(): Promise<void>;
}

export function startServer(config: Config): Promise<RunningServer> {
  return new Promise((resolve, reject) => {
    const server = createApp().listen(config.port, config.host);
    server.once("error", reject);
    server.once("listening", () => {
      server.off("error", reject);
      resolve({
        port: (server.address() as AddressInfo).port,
        close: () => close(server),
      });
    });
  });
}

function close(server: Server): Promise<void> {
  return new Promise((resolve, reject) => {
    server.close((err) => (err ? reject(err) : resolve()));
  });
}
