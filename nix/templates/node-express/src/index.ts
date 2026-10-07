import { loadConfig } from "./config.ts";
import { startServer } from "./server.ts";

const SHUTDOWN_TIMEOUT_MS = 10_000;

async function main(): Promise<void> {
  const config = loadConfig(process.env);
  const server = await startServer(config);
  console.log(`listening on http://${config.host}:${server.port}`);

  const shutdown = (signal: string): void => {
    console.log(`${signal} received, shutting down`);
    setTimeout(() => {
      console.error("shutdown timed out");
      process.exit(1);
    }, SHUTDOWN_TIMEOUT_MS).unref();
    server.close().then(
      () => process.exit(0),
      (err: unknown) => {
        console.error(err);
        process.exit(1);
      },
    );
  };
  process.once("SIGTERM", () => shutdown("SIGTERM"));
  process.once("SIGINT", () => shutdown("SIGINT"));
}

main().catch((err: unknown) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
