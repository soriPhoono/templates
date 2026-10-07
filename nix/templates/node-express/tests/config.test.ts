import { describe, expect, it } from "vitest";
import { loadConfig } from "../src/config.ts";

describe("loadConfig", () => {
  it("uses defaults when nothing is set", () => {
    expect(loadConfig({})).toEqual({ port: 3000, host: "127.0.0.1" });
  });

  it("reads PORT and HOST", () => {
    expect(loadConfig({ PORT: "8080", HOST: "0.0.0.0" })).toEqual({
      port: 8080,
      host: "0.0.0.0",
    });
  });

  it("treats empty PORT and HOST as unset", () => {
    expect(loadConfig({ PORT: "", HOST: "" })).toEqual({
      port: 3000,
      host: "127.0.0.1",
    });
  });

  it.each(["1", "65535"])("accepts the boundary port %s", (port) => {
    expect(loadConfig({ PORT: port }).port).toBe(Number(port));
  });

  it.each([
    "abc",
    "3000abc",
    "0x10",
    "3e3",
    "3.5",
    "-1",
    "0",
    "65536",
    " 3000",
  ])("rejects PORT=%j and names the variable", (port) => {
    expect(() => loadConfig({ PORT: port })).toThrow(/PORT/);
  });
});
