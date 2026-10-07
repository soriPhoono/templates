import request from "supertest";
import { describe, expect, it } from "vitest";
import { createApp } from "../src/app.ts";

describe("createApp", () => {
  const app = createApp();

  it("reports health", async () => {
    const res = await request(app).get("/healthz");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });

  it("answers HEAD on the health route", async () => {
    expect((await request(app).head("/healthz")).status).toBe(200);
  });

  it("serves the sample route", async () => {
    const res = await request(app).get("/api/hello");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ message: "Hello, world" });
  });

  it("returns 404 for other methods and unknown paths", async () => {
    expect((await request(app).post("/healthz")).status).toBe(404);
    expect((await request(app).get("/nope")).status).toBe(404);
  });

  it("does not advertise the framework", async () => {
    const res = await request(app).get("/healthz");
    expect(res.headers["x-powered-by"]).toBeUndefined();
  });
});
