import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // 开发环境中禁用 CSP，避免干扰调试
  // 生产环境应该启用严格的 CSP
  async headers() {
    // 只在生产环境启用 CSP
    if (process.env.NODE_ENV === "production") {
      return [
        {
          source: "/:path*",
          headers: [
            {
              key: "Content-Security-Policy",
              value: [
                "default-src 'self'",
                "script-src 'self' 'unsafe-eval' 'unsafe-inline'",
                "style-src 'self' 'unsafe-inline'",
                "img-src 'self' data: https:",
                "connect-src 'self' https: wss:",
              ].join("; "),
            },
          ],
        },
      ];
    }
    return [];
  },
};

export default nextConfig;
