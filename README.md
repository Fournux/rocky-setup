<h1 align="center">Rocky Setup</h1>

<p align="center">
  <strong>
    My personal Rocky Linux server setup, automated with Ansible.
  </strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Rocky_Linux-10-10b981?style=flat-square&logo=rockylinux&logoColor=white" alt="Rocky Linux">
  <img src="https://img.shields.io/badge/Home_Assistant-OS-41bdf5?style=flat-square&logo=homeassistant&logoColor=white" alt="Home Assistant">
  <img src="https://img.shields.io/badge/WireGuard-VPN-88171a?style=flat-square&logo=wireguard&logoColor=white" alt="WireGuard">
  <img src="https://img.shields.io/badge/KVM-QEMU-ff6600?style=flat-square&logo=qemu&logoColor=white" alt="KVM/QEMU">
  <img src="https://img.shields.io/badge/Ansible-Automation-ee0000?style=flat-square&logo=ansible&logoColor=white" alt="Ansible">

<p align="center">
  <img src="./dashboard.png" alt="Home Assistant Dashboard" width="1280">
</p>

## Purpose

This home server acts as the core infrastructure for home automation and self-hosted services.

- **Home Assistant OS** in KVM/libvirt for smart home automation.
- **WireGuard VPN** server for secure remote access (`57100/udp`).

## Ansible Vault password

> `vault_password_file` is intentionally omitted from `ansible.cfg`; `bootstrap.sh` supplies it only for `run` and `check`, so lint and CI do not depend on a local secret.

## Requirements

- Fresh Rocky Linux 10.x host
- Regular user in `wheel` (Sudoer)
- Wired network interface named `enp3s0`

If your interface name differs, update `lan_interface` and `lan_connection` in `group_vars/all/main.yml`.

## Access

- **Cockpit Web Console**: `https://rocky-server.local:9090`
- **Home Assistant**: `http://homeassistant.local`
- **WireGuard VPN**: `57100/udp` (tunnel subnet `10.10.0.0/24`)
