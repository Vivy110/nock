# CARA RUN 

16GB > 6CORE 

 ```bash
git clone https://github.com/Vivy110/nock.git
cd nock

chmod +x nockinstall.sh
./nockinstall.sh
 ```
tunggu sampai selesai!!

# simpan public key dan private key

salin lalu paste public key ke Makefile

 ```bash
nano Makefile
```

export MINING_PUBKEY := (Public Key)

ctrl+x y enter 

# BUAT SCREEN

buat screen untuk memulai mining

untuk leader 

```bash
screen -S leader
 ```

```bash
make run-nockchain-leader
 ```

untuk follower 

```bash
screen -S follower
 ```

```bash
make run-nockchain-follower
 ```

# JIKA TERJADI ERROR SEPERTI DI BAWAH

![image](https://github.com/user-attachments/assets/0a76cd8a-a48d-4c53-bc15-39760b8d0ef0)

itu berarti ram/core tidak mampu 
bisa tetap di jalankan tapi akan memakan waktu 

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
 ```

mulai ulang step ke 1

# COMMAND UNTUK CHECK WALLET

```bash
nockchain-wallet show-seedphrase
 ```
untuk lihat seed phrase

```bash
nockchain-wallet show-master-privkey
```
untuk lihat private key

```bash
nockchain-wallet show-master-pubkey
```
untuk lihat publik key

```bash
nockchain-wallet keygen
```
untuk membuat ulang privkey,pubkey,seedphrase


# SELAMAT MINING

https://x.com/diva_hashimoto


