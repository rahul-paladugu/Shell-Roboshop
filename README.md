# 🤖 Shell-Roboshop

Automated shell scripts to deploy the **RoboShop** e-commerce application — a microservices-based demo store — on RHEL/CentOS/Rocky Linux servers.

Each script handles the full installation, configuration, and service activation for one component of the stack, with coloured output, error handling, and execution-time reporting built in.

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Deployment Order](#deployment-order)
- [Scripts Reference](#scripts-reference)
- [Utility Scripts](#utility-scripts)
- [Usage](#usage)
- [Logs](#logs)
- [Project Structure](#project-structure)

---

## 🏗️ Architecture Overview

RoboShop is composed of several microservices backed by different data stores and message brokers:

```
Frontend (Nginx)
      │
      ├── Catalogue  ──► MongoDB
      ├── User       ──► MongoDB + Redis
      ├── Cart       ──► Redis
      ├── Shipping   ──► MySQL
      ├── Payment    ──► RabbitMQ
      └── Dispatch   ──► RabbitMQ
```

---

## ✅ Prerequisites

- RHEL 8 / Rocky Linux 8 (or compatible)
- `root` or `sudo` access on each target server
- Internet connectivity to download packages
- Scripts cloned to the same directory (some scripts reference local config files like `mongo.repo`, `rabbitmq.repo`, and `*.service` files)

---

## 🚀 Deployment Order

Scripts are numbered to reflect the recommended installation sequence:

| Order | Script | Component |
|-------|--------|-----------|
| 1 | `1-mongodb.sh` | MongoDB |
| 2 | `2-catalogue.sh` | Catalogue Service |
| 3 | `3-redis.sh` | Redis |
| 4 | `4-user.sh` | User Service |
| 5 | `5-cart.sh` | Cart Service |
| 6 | `6-mysql.sh` | MySQL |
| 7 | `7-shipping.sh` | Shipping Service |
| 8 | `8-rabbitmq.sh` | RabbitMQ |
| 9 | `9-payment.sh` | Payment Service |
| 10 | `10-dispatch.sh` | Dispatch Service |
| 11 | `11-frontend.sh` | Frontend (Nginx) |

---

## 📜 Scripts Reference

### 1. `1-mongodb.sh`
Installs and configures MongoDB. Copies the custom `mongo.repo`, installs `mongodb-org` via `dnf`, enables and starts `mongod`, then binds the service to `0.0.0.0` so other services can connect.

### 2. `2-catalogue.sh`
Sets up the Node.js-based Catalogue microservice. Installs Node.js, downloads the Roboshop release, installs npm dependencies, loads the `catalogue.service` systemd unit, and populates the MongoDB database with product data.

### 3. `3-redis.sh`
Installs Redis from the default package repository, configures it to listen on all interfaces, and starts the service.

### 4. `4-user.sh`
Deploys the User microservice (Node.js). Installs dependencies, configures the `user.service` systemd unit, and connects to both MongoDB and Redis.

### 5. `5-cart.sh`
Deploys the Cart microservice (Node.js) backed by Redis. Installs the app, registers `cart.service`, and starts the service.

### 6. `6-mysql.sh`
Installs MySQL 8, secures the root account, creates the Roboshop schema, and loads the shipping data required by the Shipping service.

### 7. `7-shipping.sh`
Deploys the Java-based Shipping microservice. Installs Maven/Java, builds the application, registers `shipping.service`, and connects to MySQL.

### 8. `8-rabbitmq.sh`
Installs RabbitMQ using the custom `rabbitmq.repo`, creates the application user, and starts the broker.

### 9. `9-payment.sh`
Deploys the Python-based Payment microservice. Installs Python 3 dependencies, registers `payment.service`, and connects to RabbitMQ.

### 10. `10-dispatch.sh`
Deploys the Go-based Dispatch microservice responsible for order dispatch notifications. Registers `dispatch.service` and connects to RabbitMQ.

### 11. `11-frontend.sh`
Installs Nginx, deploys the RoboShop static frontend, and configures reverse-proxy rules to route API calls to the relevant backend services.

---

## 🛠️ Utility Scripts

| Script | Purpose |
|--------|---------|
| `instances.sh` | Helper to provision or list the required server instances |
| `Delete-old-logs.sh` | Cleans up log files older than a configurable number of days from `/var/logs/shell-roboshop/` |

---

## ▶️ Usage

> Run each script **as root** in the numbered order on the appropriate server.

```bash
# Clone the repository
git clone https://github.com/rahul-paladugu/Shell-Roboshop.git
cd Shell-Roboshop

# Make scripts executable
chmod +x *.sh

# Example: install MongoDB
sudo bash 1-mongodb.sh
```

Each script will print colour-coded status messages:
- 🟢 **Green** — step succeeded
- 🔴 **Red** — step failed (script exits immediately)
- 🟡 **Yellow** — informational / in-progress

---

## 📁 Logs

All script output is saved to:

```
/var/logs/shell-roboshop/<script-name>.log
```

Use these logs for troubleshooting failed steps.

---

## 📂 Project Structure

```
Shell-Roboshop/
├── 1-mongodb.sh          # MongoDB setup
├── 2-catalogue.sh        # Catalogue service
├── 3-redis.sh            # Redis setup
├── 4-user.sh             # User service
├── 5-cart.sh             # Cart service
├── 6-mysql.sh            # MySQL setup
├── 7-shipping.sh         # Shipping service
├── 8-rabbitmq.sh         # RabbitMQ setup
├── 9-payment.sh          # Payment service
├── 10-dispatch.sh        # Dispatch service
├── 11-frontend.sh        # Nginx frontend
├── instances.sh          # Instance helper
├── Delete-old-logs.sh    # Log cleanup utility
├── mongo.repo            # MongoDB yum repo config
├── rabbitmq.repo         # RabbitMQ yum repo config
├── cart.service          # systemd unit — Cart
├── catalogue.service     # systemd unit — Catalogue
├── dispatch.service      # systemd unit — Dispatch
├── nginx.service         # systemd unit — Nginx
├── payment.service       # systemd unit — Payment
├── shipping.service      # systemd unit — Shipping
└── user.service          # systemd unit — User
```

---

## 🪪 License

This project is intended for learning and demo purposes.
