export interface Config {
  port: number;
  host: string;
}

const DEFAULT_PORT = 3000;
const DEFAULT_HOST = "127.0.0.1";

export function loadConfig(env: Record<string, string | undefined>): Config {
  return { port: parsePort(env.PORT), host: env.HOST || DEFAULT_HOST };
}

function parsePort(raw: string | undefined): number {
  if (raw === undefined || raw === "") return DEFAULT_PORT;
  const port = /^\d{1,5}$/.test(raw) ? Number(raw) : Number.NaN;
  if (!(port >= 1 && port <= 65535)) {
    throw new Error(
      `PORT must be an integer from 1 to 65535, got ${JSON.stringify(raw)}`,
    );
  }
  return port;
}
