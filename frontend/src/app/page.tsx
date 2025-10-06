"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TokenBankDashboard } from "@/components/token-bank-dashboard";
import { MarketEventsListener } from "@/components/market-events-listener";

export default function Home() {
  const { address } = useAccount();

  return (
    <main className="min-h-screen bg-background">
      <div className="container mx-auto max-w-4xl py-8 space-y-6">
        <header className="flex items-center justify-between">
          <Card className="w-full">
            <CardHeader className="flex flex-row items-center justify-between">
              <div>
                <CardTitle className="text-2xl font-semibold">
                  TokenBank Dashboard
                </CardTitle>
                <p className="text-sm text-muted-foreground">
                  Manage your deposits and withdrawals using MyERC20 tokens.
                </p>
              </div>
              <ConnectButton showBalance={false} chainStatus="icon" />
            </CardHeader>
            <CardContent>
              <MarketEventsListener />
            </CardContent>
          </Card>
        </header>

        <section>
          <TokenBankDashboard address={address} />
        </section>
      </div>
    </main>
  );
}
