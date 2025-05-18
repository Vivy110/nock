#!/bin/bash

set -e

echo -e "\n📦 Memperbarui sistem dan menginstal dependensi..."
apt-get update && apt install -y screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

echo -e "\n🦀 Menginstal Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustup default stable

echo -e "\n📁 Mengecek repositori nockchain..."
if [ -d "nockchain" ]; then
  echo "⚠️ Direktori nockchain sudah ada. Apakah ingin menghapus dan mengkloning ulang? (harus pilih y) (y/n)"
  read -r confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    rm -rf nockchain
    git clone https://github.com/zorp-corp/nockchain
  else
    echo "➡️ Menggunakan direktori nockchain yang sudah ada"
  fi
else
  git clone https://github.com/zorp-corp/nockchain
fi

cd nockchain

echo -e "\n🔧 Memulai proses kompilasi komponen utama..."
make install-hoonc || { echo "❌ Gagal: install-hoonc"; exit 1; }
make build || { echo "❌ Gagal: build"; exit 1; }
make install-nockchain-wallet || { echo "❌ Gagal: install wallet"; exit 1; }
make install-nockchain || { echo "❌ Gagal: install nockchain"; exit 1; }

echo -e "\n✅ Kompilasi selesai, menambahkan environment variable..."
echo 'export PATH="$PATH:$HOME/nockchain/target/release"' >> ~/.bashrc
echo 'export RUST_LOG=info' >> ~/.bashrc
echo 'export MINIMAL_LOG_FORMAT=true' >> ~/.bashrc
source ~/.bashrc

# === Generate Wallet ===
echo -e "\n🔐 Membuat seed phrase dan master private key secara otomatis..."
WALLET_CMD=$(which nockchain-wallet || echo "./target/release/nockchain-wallet")
if [ ! -f "$WALLET_CMD" ]; then
  echo "❌ Wallet command tidak ditemukan: $WALLET_CMD"
  exit 1
fi

SEED_OUTPUT=$($WALLET_CMD keygen)
echo "$SEED_OUTPUT"

SEED_PHRASE=$(echo "$SEED_OUTPUT" | grep -iE "seedphrase" | sed 's/.*: //')
if [ -z "$SEED_PHRASE" ]; then
  echo "❌ Gagal mengambil seedphrase."
fi

echo -e "\n🧠 seedphrase: $SEED_PHRASE"

echo -e "\n🔑 Menghasilkan master private key dari seedphrase..."
MASTER_PRIVKEY=$($WALLET_CMD gen-master-privkey --seedphrase "$SEED_PHRASE" | grep -i "master private key" | awk '{print $NF}')
echo "Master Private Key: $MASTER_PRIVKEY"

MASTER_PUBKEY=$($WALLET_CMD gen-master-pubkey --master-privkey "$MASTER_PRIVKEY" | grep -i "master public key" | awk '{print $NF}')
echo "Master Public Key: $MASTER_PUBKEY"

if [ -z "$MASTER_PRIVKEY" ] || [ -z "$MASTER_PUBKEY" ]; then
  echo "❌ Gagal menghasilkan key dari mnemonic."
fi

echo -e "\n📄 Menuliskan public key ke dalam Makefile untuk mining..."
sed -i "s|^export MINING_PUBKEY :=.*$|export MINING_PUBKEY := $MASTER_PUBKEY|" Makefile

# === Opsional: Inisialisasi pengujian choo hoon ===
read -p $'\n🌀 Apakah ingin menjalankan pengujian awal choo? Langkah ini bisa terlihat seperti hang, tidak wajib. Ketik y untuk lanjut: ' confirm_choo
if [[ "$confirm_choo" == "y" || "$confirm_choo" == "Y" ]]; then
  mkdir -p hoon assets
  echo "%trivial" > hoon/trivial.hoon
  if ! command -v choo &> /dev/null; then
    echo "⚠️ Perintah 'choo' tidak ditemukan. Lewati pengujian choo."
  else
    echo -e "\n🔍 Menjalankan 'choo --new --arbitrary hoon/trivial.hoon'..."
    choo --new --arbitrary hoon/trivial.hoon > choo.log 2>&1
    if [ $? -ne 0 ]; then
      echo "❌ choo gagal. Log error:\n"
      cat choo.log
    elif [ -f "out.jam" ]; then
      mv out.jam assets/dumb.jam
      echo "✅ Berhasil memindahkan out.jam ke assets/dumb.jam"
    else
      echo "❌ Gagal: out.jam tidak ditemukan. Kemungkinan error pada choo."
    fi
  fi
fi

# === Panduan Menjalankan Node ===
echo -e "\n🚀 Konfigurasi selesai. Gunakan perintah berikut untuk menjalankan node:"

echo -e "\n➡️ Menjalankan node leader:"
echo -e "screen -S leader\nmake run-nockchain-leader"

echo -e "\n➡️ Menjalankan node follower:"
echo -e "screen -S follower\nmake run-nockchain-follower"

echo -e "\n📄 Untuk melihat log:"
echo -e "screen -r leader   # Melihat log leader"
echo -e "screen -r follower # Melihat log follower"
echo -e "Gunakan Ctrl+A lalu tekan D untuk keluar dari screen"

echo -e "\n🎉 Instalasi dan setup selesai! Selamat menambang!"
