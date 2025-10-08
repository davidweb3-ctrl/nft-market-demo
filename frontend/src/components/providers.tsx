"use client";

import { wagmiConfig } from "@/lib/wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  RainbowKitProvider,
  darkTheme,
  lightTheme,
} from "@rainbow-me/rainbowkit";
import { ReactNode, useEffect, useState } from "react";
import { WagmiProvider } from "wagmi";

import "@rainbow-me/rainbowkit/styles.css";

export function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // 清理可能损坏的 WalletConnect 数据
    if (typeof window !== "undefined") {
      try {
        const keysToCheck = Object.keys(localStorage);
        const wcKeys = keysToCheck.filter(
          (key) =>
            key.startsWith("wc@2:") ||
            key.startsWith("-walletlink") ||
            key.includes("walletconnect")
        );
        
        // 尝试解析每个键，如果解析失败则删除
        wcKeys.forEach((key) => {
          try {
            const value = localStorage.getItem(key);
            if (value && value.includes("[object Object]")) {
              console.warn(`Removing corrupted localStorage key: ${key}`);
              localStorage.removeItem(key);
            } else if (value) {
              JSON.parse(value); // 测试是否能解析
            }
          } catch (e) {
            console.warn(`Removing invalid localStorage key: ${key}`, e);
            localStorage.removeItem(key);
          }
        });
      } catch (e) {
        console.error("Error cleaning localStorage:", e);
      }
    }
    setMounted(true);
  }, []);

  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        {mounted ? (
          <RainbowKitProvider>{children}</RainbowKitProvider>
        ) : (
          children
        )}
      </QueryClientProvider>
    </WagmiProvider>
  );
}
