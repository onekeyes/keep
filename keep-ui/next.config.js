const withNextIntl = require('next-intl/plugin')(
  // This is the default (also the `src` folder is supported out of the box)
  './i18n.ts'
);

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Your existing Next.js config
  experimental: {
    turbo: {
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js',
        },
      },
    },
  },
  webpack: (config) => {
    config.module.rules.push({
      test: /\.svg$/,
      use: ['@svgr/webpack'],
    });
    return config;
  },
  images: {
    domains: ['localhost'],
  },
  env: {
    KEEP_VERSION: process.env.KEEP_VERSION,
    GIT_COMMIT_HASH: process.env.GIT_COMMIT_HASH,
    SHOW_BUILD_INFO: process.env.SHOW_BUILD_INFO,
  },
};

module.exports = withNextIntl(nextConfig);