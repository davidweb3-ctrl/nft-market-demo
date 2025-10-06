"use client";

import { useEffect, useMemo, useState } from "react";
import { useAccount, useReadContract, useWriteContract } from "wagmi";
import { erc20Abi, parseUnits, formatUnits } from "viem";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import { tokenBankAbi, deployments } from "@nft-market-demo/contracts";

const DEFAULT_CHAIN_ID = Number(process.env.NEXT_PUBLIC_CHAIN_ID || 31337);
const DEFAULT_TOKEN_ADDRESS = process.env.NEXT_PUBLIC_TOKEN_ADDRESS;

interface TokenBankDashboardProps {
  address?: `0x${string}`;
}

export function TokenBankDashboard({ address }: TokenBankDashboardProps) {
  const deployment = useMemo(
    () => deployments.find((d) => d.chainId === DEFAULT_CHAIN_ID),
    []
  );

  const [amount, setAmount] = useState("0");
  const tokenBankAddress = deployment?.address;
  const tokenAddress = DEFAULT_TOKEN_ADDRESS as `0x${string}` | undefined;

  const { data: tokenBalance, refetch: refetchTokenBalance } = useReadContract({
    address: tokenAddress,
    abi: erc20Abi,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
    query: {
      enabled: Boolean(address && tokenAddress),
    },
  });

  const { data: bankBalance, refetch: refetchBankBalance } = useReadContract({
    address: tokenBankAddress,
    abi: tokenBankAbi,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
    query: {
      enabled: Boolean(address && tokenBankAddress),
    },
  });

  const { writeContractAsync, isPending } = useWriteContract();

  const decimals = 18;

  async function handleDeposit() {
    if (!address || !tokenAddress || !tokenBankAddress) return;
    const parsed = parseUnits(amount, decimals);

    await writeContractAsync({
      address: tokenAddress,
      abi: erc20Abi,
      functionName: "approve",
      args: [tokenBankAddress, parsed],
    });

    await writeContractAsync({
      address: tokenBankAddress,
      abi: tokenBankAbi,
      functionName: "deposit",
      args: [parsed],
    });

    await Promise.all([refetchTokenBalance(), refetchBankBalance()]);
  }

  async function handleWithdraw() {
    if (!address || !tokenBankAddress) return;
    const parsed = parseUnits(amount, decimals);

    await writeContractAsync({
      address: tokenBankAddress,
      abi: tokenBankAbi,
      functionName: "withdraw",
      args: [parsed],
    });

    await Promise.all([refetchTokenBalance(), refetchBankBalance()]);
  }

  const formattedTokenBalance = tokenBalance
    ? formatUnits(tokenBalance as bigint, decimals)
    : "0";
  const formattedBankBalance = bankBalance
    ? formatUnits(bankBalance as bigint, decimals)
    : "0";

  if (!address) {
    return (
      <Alert>
        <AlertTitle>Wallet not connected</AlertTitle>
        <AlertDescription>
          Connect your wallet to view balances and manage TokenBank funds.
        </AlertDescription>
      </Alert>
    );
  }

  if (!tokenBankAddress || !tokenAddress) {
    return (
      <Alert variant="destructive">
        <AlertTitle>Configuration missing</AlertTitle>
        <AlertDescription>
          TokenBank deployment or token address is not configured for chain {""}
          {DEFAULT_CHAIN_ID}.
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Account Overview</CardTitle>
        <CardDescription>{address}</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid gap-4 sm:grid-cols-2">
          <BalanceTile
            title="Wallet Balance"
            value={`${formattedTokenBalance} MTK`}
          />
          <BalanceTile
            title="TokenBank Balance"
            value={`${formattedBankBalance} MTK`}
          />
        </div>
        <div className="grid gap-4 sm:grid-cols-[2fr_1fr_1fr]">
          <div>
            <Input
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="Amount in MTK"
              className="h-12"
            />
          </div>
          <Button
            variant="default"
            onClick={handleDeposit}
            disabled={isPending}
            className="h-12"
          >
            Deposit
          </Button>
          <Button
            variant="secondary"
            onClick={handleWithdraw}
            disabled={isPending}
            className="h-12"
          >
            Withdraw
          </Button>
        </div>
      </CardContent>
      <CardFooter>
        <p className="text-xs text-muted-foreground">
          Approvals are handled automatically before deposits. Ensure you are on
          the correct network (chain ID {DEFAULT_CHAIN_ID}).
        </p>
      </CardFooter>
    </Card>
  );
}

function BalanceTile({
  title,
  value,
}: {
  title: string;
  value: string;
}) {
  return (
    <Card className="bg-muted/40">
      <CardHeader className="pb-2">
        <CardDescription>{title}</CardDescription>
        <CardTitle className="text-2xl font-semibold">{value}</CardTitle>
      </CardHeader>
    </Card>
  );
}
