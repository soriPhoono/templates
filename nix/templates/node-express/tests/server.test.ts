import http from "node:http";
import express from "express";
import { describe, expect, it } from "vitest";
import { startServer } from "../src/server.ts";

const local = { port: 0, host: "127.0.0.1" };

function get(port: number, path: string, agent: http.Agent): Promise<number> {
  return new Promise((resolve, reject) => {
    http
      .get({ host: "127.0.0.1", port, path, agent }, (res) => {
        res.resume();
        res.on("end", () => resolve(res.statusCode ?? 0));
      })
      .on("error", reject);
  });
}

describe("startServer", () => {
  it("serves requests on the bound port", async () => {
    const server = await startServer(local);
    try {
      const res = await fetch(`http://127.0.0.1:${server.port}/healthz`);
      expect(await res.json()).toEqual({ status: "ok" });
    } finally {
      await server.close();
    }
  });

  it("rejects with EADDRINUSE when the port is taken", async () => {
    const first = await startServer(local);
    try {
      await expect(
        startServer({ port: first.port, host: "127.0.0.1" }),
      ).rejects.toMatchObject({ code: "EADDRINUSE" });
    } finally {
      await first.close();
    }
  });

  it("closes promptly despite an idle keep-alive connection", async () => {
    const server = await startServer(local);
    const agent = new http.Agent({ keepAlive: true });
    await new Promise<void>((resolve, reject) => {
      http
        .get(
          { host: "127.0.0.1", port: server.port, path: "/healthz", agent },
          (res) => {
            res.resume();
            res.on("end", resolve);
          },
        )
        .on("error", reject);
    });
    const started = Date.now();
    await server.close();
    agent.destroy();
    expect(Date.now() - started).toBeLessThan(1000);
  });

  it("closes promptly while a keep-alive client keeps sending requests", async () => {
    const app = express();
    app.get("/slow", (_req, res) => {
      setTimeout(() => res.json({ ok: true }), 300);
    });
    const server = await startServer(local, app);
    const agent = new http.Agent({ keepAlive: true, maxSockets: 1 });
    const statuses: number[] = [];
    let stop = false;
    const loop = (async () => {
      while (!stop) {
        try {
          statuses.push(await get(server.port, "/slow", agent));
        } catch {
          break;
        }
      }
    })();
    await new Promise((resolve) => setTimeout(resolve, 100));
    const started = Date.now();
    await server.close();
    const elapsed = Date.now() - started;
    stop = true;
    await loop;
    agent.destroy();
    expect(statuses[0]).toBe(200);
    expect(elapsed).toBeLessThan(2000);
  });
});
