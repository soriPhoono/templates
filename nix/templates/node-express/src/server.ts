import type { Server } from "node:http";
import type { AddressInfo } from "node:net";
import type { Express } from "express";
import { createApp } from "./app.ts";
import type { Config } from "./config.ts";

export interface RunningServer {
  port: number;
  close(): Promise<void>;
}

export function startServer(
  config: Config,
  app: Express = createApp(),
): Promise<RunningServer> {
  return new Promise((resolve, reject) => {
    const server = app.listen(config.port, config.host);
    let closing = false;

    // server.close() only drops connections that are idle at that moment. Once
    // closing, tell clients to disconnect and drop each connection as its
    // response finishes, so a busy keep-alive client cannot stall shutdown.
    // Registered first so Connection: close is set before the handler responds.
    server.prependListener("request", (_req, res) => {
      if (closing) res.setHeader("Connection", "close");
      res.on("finish", () => {
        if (closing) setImmediate(() => server.closeIdleConnections());
      });
    });

    server.once("error", reject);
    server.once("listening", () => {
      server.off("error", reject);
      resolve({
        port: (server.address() as AddressInfo).port,
        close: () => {
          closing = true;
          return close(server);
        },
      });
    });
  });
}

function close(server: Server): Promise<void> {
  return new Promise((resolve, reject) => {
    server.close((err) => (err ? reject(err) : resolve()));
    server.closeIdleConnections();
  });
}
