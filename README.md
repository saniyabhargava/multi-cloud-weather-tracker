# Multi-Cloud Weather Tracker

A weather dashboard designed to **run across multiple clouds** using a single codebase and Terraform.

The app is a React single-page application that talks to a simple weather proxy/backend and is designed to be deployed to:

- **AWS** – S3 static website
- **Azure** – Storage static website fronted by **Traffic Manager** for failover
- **OCI** – Object Storage static website (infrastructure defined, ready to enable)

---

## Tech Stack

- **Frontend:** React + Vite
- **Backend:** Lightweight weather proxy (Azure Functions / Node.js)
- **Cloud Providers:**
  - AWS – S3, optional Route53
  - Azure – Resource Group, Storage Account static website, Traffic Manager
  - OCI – Object Storage (static hosting)
- **IaC:** Terraform

---

## Features

- Single-page weather dashboard built with React
- Infrastructure-as-Code for:
  - AWS S3 static hosting
  - Azure static website + Traffic Manager failover
  - OCI Object Storage static website (optional)
- Shared tagging and naming conventions across providers
- Optional Route53 DNS record pointing to Azure Traffic Manager

---

## Architecture Overview

**High-level flow:**

1. The React app is built once using Vite (`npm run build`).
2. The static files in `frontend/dist` are deployed to:
   - an **S3 bucket** configured as a static website,
   - an **Azure Storage Account** static website,
   - optionally an **OCI Object Storage** bucket.
3. **Azure Traffic Manager** is configured in *Priority* mode:
   - **Primary:** AWS S3 website endpoint
   - **Secondary:** Azure static website endpoint
4. Optionally, **Route53** can create a CNAME pointing at the Traffic Manager DNS name.

This gives a simple, easy-to-explain demo of **multi-cloud hosting and failover** using only static assets and DNS.

---

## Repository Structure

```text
.
├── backend/
│   └── azure-functions-weather/
│       └── WeatherProxy/    # Node.js Azure Function proxy for the weather API
│           ├── index.js
│           ├── function.json
│           ├── host.json
│           └── package.json
│
├── frontend/
│   ├── src/
│   │   ├── main.jsx
│   │   └── App.jsx
│   ├── index.html
│   ├── package.json
│   ├── vite.config.js
│   └── .env (not committed – contains API key)
│
└── infra/
    ├── providers.tf
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars.example
```

Running the Frontend Locally
```
cd frontend
npm install
npm run dev
```
Then open http://localhost:5173.

The frontend expects an environment variable for the weather API key:
```
VITE_OPENWEATHER_API_KEY=your_api_key_here
```
