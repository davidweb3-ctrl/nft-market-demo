import { cookieStorage, createStorage } from "wagmi";
import { createConfig, http } from "wagmi";
import { mainnet, sepolia } from "wagmi/chains";
import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { defineChain } from "viem";

const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || "demo";

// 定义 Anvil 本地链 (Chain ID 31337)
const anvil = defineChain({
  id: 31337,
  name: "Anvil (Localhost)",
  nativeCurrency: {
    decimals: 18,
    name: "Ether",
    symbol: "ETH",
  },
  rpcUrls: {
    default: {
      http: ["http://127.0.0.1:8545"],
    },
  },
});

// 为 SSR 提供 indexedDB mock
if (typeof window === "undefined") {
  const mockIDBRequest = {
    onsuccess: null,
    onerror: null,
    result: null,
  };
  
  (global as any).indexedDB = {
    open: () => mockIDBRequest,
    deleteDatabase: () => mockIDBRequest,
  };
}

export const wagmiConfig = getDefaultConfig({
  appName: "NFT Market Demo",
  projectId,
  chains: [anvil, sepolia, mainnet],
  ssr: true,
  storage: createStorage({
    storage: cookieStorage,
  }),
  transports: {
    [anvil.id]: http("http://127.0.0.1:8545"),
    [sepolia.id]: http(),
    [mainnet.id]: http(),
  },
});
