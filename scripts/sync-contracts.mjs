import { readFile, writeFile, mkdir } from "node:fs/promises";
import { dirname, join } from "node:path";

const artifacts = [
  {
    source: "out/TokenBank.sol/TokenBank.json",
    target: "packages/contracts/src/abi/TokenBank.json",
  },
];

async function main() {
  for (const { source, target } of artifacts) {
    const data = await readFile(source, "utf-8");
    await mkdir(dirname(target), { recursive: true });
    await writeFile(target, data);
    console.log(`Synced ${source} -> ${target}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
