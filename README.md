# skonadesk-hbbs

Patched `hbbs` (RustDesk rendezvous server) for the [SkonaDesk](https://github.com/Skonamonkey/skonadesk) stack.

This is a fork of [rustdesk/rustdesk-server](https://github.com/rustdesk/rustdesk-server) with two targeted patches applied. It is not intended to be used standalone — it is built as a Docker image and consumed by the SkonaDesk stack.

---

## What is patched and why

### 1. JWT relay authentication

The stock `hbbs` accepts `PunchHoleRequest` connections from any client. This fork validates a JWT token in every `PunchHoleRequest` — clients without a valid token receive a `LICENSE_MISMATCH` response before any relay traffic flows.

The JWT is issued by the SkonaDesk API on login. Only users with a SkonaDesk account can initiate connections through the server.

### 2. KeyExchange handshake

When a RustDesk client has an active API session it calls `secure_tcp()` before sending a `PunchHoleRequest`. This waits for the server to send a `KeyExchange` message. The stock `hbbs` never initiates one — both sides wait indefinitely, causing a connection timeout.

This fork implements the correct two-phase KeyExchange handshake: on each new TCP connection the server sends its signed ephemeral public key (phase 1), the client responds with its own (phase 2), and both sides derive a shared symmetric key (XSalsa20-Poly1305). All subsequent rendezvous traffic on that connection is encrypted.

---

## Usage

Pre-built images are published to GHCR and pulled automatically by the SkonaDesk stack:

```
ghcr.io/skonamonkey/skonadesk-hbbs:latest
```

See the [SkonaDesk repo](https://github.com/Skonamonkey/skonadesk) for full setup instructions.

## Building from source

```bash
git clone https://github.com/Skonamonkey/skonadesk-hbbs.git
cd skonadesk-hbbs
git submodule update --init --recursive
docker build --no-cache -f Dockerfile.skonadesk -t skonadesk-hbbs:latest .
```

---

## Upstream

Forked from [rustdesk/rustdesk-server](https://github.com/rustdesk/rustdesk-server) — AGPL-3.0.
