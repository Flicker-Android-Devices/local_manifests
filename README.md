- common
```bash
repo sync --detach --force-sync -j$(nproc --all) vendor/bcr vendor/lineage-priv/keys
```
- mikona common
```bash
repo sync --detach --force-sync -j$(nproc --all) device/xiaomi/sm8250-common hardware/xiaomi kernel/xiaomi/sm8250 vendor/xiaomi/sm8250-common
```
- thyme  
```bash
repo sync --detach --force-sync -j$(nproc --all) device/xiaomi/thyme device/xiaomi/camera-thyme vendor/xiaomi/thyme vendor/xiaomi/camera-thyme
```
- psyche  
```bash
repo sync --detach --force-sync -j$(nproc --all) device/xiaomi/psyche device/xiaomi/camera-psyche vendor/xiaomi/psyche vendor/xiaomi/camera-psyche
```
- lmi  
```bash
repo sync --detach --force-sync -j$(nproc --all) device/xiaomi/lmi vendor/xiaomi/lmi
```
- enuma  
```bash
repo sync --detach --force-sync -j$(nproc --all) device/xiaomi/enuma device/xiaomi/camera-enuma vendor/xiaomi/enuma vendor/xiaomi/camera-enuma
```
---
- or  
---
```bash
chmod +x .repo/local_manifests/sync_projects.sh
```
```bash
.repo/local_manifests/sync_projects.sh
```
- or  
```bash
.repo/local_manifests/sync_projects.sh common
.repo/local_manifests/sync_projects.sh thyme
.repo/local_manifests/sync_projects.sh thyme lmi
```
