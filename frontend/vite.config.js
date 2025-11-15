import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  base: "./",               // relative paths for S3/Azure static sites
  plugins: [react()],
  build: { outDir: "dist" }
});
