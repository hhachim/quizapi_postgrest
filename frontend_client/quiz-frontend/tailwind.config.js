/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
      "./src/app/**/*.{js,ts,jsx,tsx}",
      "./src/pages/**/*.{js,ts,jsx,tsx}",
      "./src/components/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
      extend: {
        colors: {
          blue: {
            50: '#ebf5ff',
            100: '#e1effe',
            200: '#c3ddfd',
            300: '#a4cafe',
            400: '#76a9fa',
            500: '#3f83f8',
            600: '#1c64f2',
            700: '#1a56db',
            800: '#1e429f',
            900: '#233876',
          },
        },
        fontFamily: {
          sans: ['var(--font-geist-sans)', 'sans-serif'],
          mono: ['var(--font-geist-mono)', 'monospace'],
        },
      },
    },
    plugins: [],
  };