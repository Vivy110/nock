# CARA RUN 

 ```bash
git clone https://github.com/Vivy110/nock.git
cd nock
chmod +x nockinstall.sh
./nockinstall.sh
 ```

# BUAT SCREEN
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
# SELAMAT MINING

https://x.com/diva_hashimoto


