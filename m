From: Chris Mi <chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [patch net-next 1/3] idr: Use unsigned long instead of int
Date: Tue, 15 Aug 2017 22:12:16 -0400
Message-ID: <1502849538-14284-2-git-send-email-chrism@mellanox.com>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1502849538-14284-1-git-send-email-chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/nbd-general>,
 <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nbd-general>
List-Post: <mailto:nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nbd-general>,
 <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org, sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org, markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org, zhi.a.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, jinpu.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org, sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, AlexBin.Xie-5C7GfCeVMHo@public.gmane.org, david1.zhou-5C7GfCeVMHo@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sudarsana.kalluru-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dtwlin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, michel.daenzer-5C7GfCeVMHo@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, tpmdd-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, longman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, pmladek-IBi9RG/b67k@public.gmane.org, dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.orglinux-
List-Id: linux-mm.kvack.org

IDR uses internally radix tree which uses unsigned long. It doesn't
makes sense to have index as signed value.

Signed-off-by: Chris Mi <chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 block/bsg.c                                     |  8 ++--
 block/genhd.c                                   | 12 +++---
 drivers/atm/nicstar.c                           | 11 ++---
 drivers/block/drbd/drbd_main.c                  | 31 ++++++++------
 drivers/block/drbd/drbd_nl.c                    | 22 +++++-----
 drivers/block/drbd/drbd_proc.c                  |  3 +-
 drivers/block/drbd/drbd_receiver.c              | 15 ++++---
 drivers/block/drbd/drbd_state.c                 | 34 ++++++++-------
 drivers/block/drbd/drbd_worker.c                |  6 +--
 drivers/block/loop.c                            | 17 +++++---
 drivers/block/nbd.c                             | 20 +++++----
 drivers/block/zram/zram_drv.c                   |  9 ++--
 drivers/char/tpm/tpm-chip.c                     | 10 +++--
 drivers/char/tpm/tpm.h                          |  2 +-
 drivers/dca/dca-sysfs.c                         |  9 ++--
 drivers/firewire/core-cdev.c                    | 18 ++++----
 drivers/firewire/core-device.c                  | 15 ++++---
 drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c     |  8 ++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_ctx.c         |  9 ++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c         |  6 +--
 drivers/gpu/drm/amd/amdgpu/amdgpu_kms.c         |  2 +-
 drivers/gpu/drm/drm_auth.c                      |  9 ++--
 drivers/gpu/drm/drm_connector.c                 | 10 +++--
 drivers/gpu/drm/drm_context.c                   | 20 +++++----
 drivers/gpu/drm/drm_dp_aux_dev.c                | 11 ++---
 drivers/gpu/drm/drm_drv.c                       |  6 ++-
 drivers/gpu/drm/drm_gem.c                       | 19 +++++----
 drivers/gpu/drm/drm_info.c                      |  2 +-
 drivers/gpu/drm/drm_mode_object.c               | 11 +++--
 drivers/gpu/drm/drm_syncobj.c                   | 18 +++++---
 drivers/gpu/drm/exynos/exynos_drm_ipp.c         | 25 ++++++-----
 drivers/gpu/drm/i915/gvt/display.c              |  2 +-
 drivers/gpu/drm/i915/gvt/kvmgt.c                |  2 +-
 drivers/gpu/drm/i915/gvt/vgpu.c                 |  9 ++--
 drivers/gpu/drm/i915/i915_debugfs.c             |  6 +--
 drivers/gpu/drm/i915/i915_gem_context.c         |  9 ++--
 drivers/gpu/drm/qxl/qxl_cmd.c                   |  8 ++--
 drivers/gpu/drm/qxl/qxl_release.c               | 14 +++---
 drivers/gpu/drm/sis/sis_mm.c                    |  8 ++--
 drivers/gpu/drm/tegra/drm.c                     | 10 +++--
 drivers/gpu/drm/tilcdc/tilcdc_slave_compat.c    |  3 +-
 drivers/gpu/drm/vgem/vgem_fence.c               | 12 +++---
 drivers/gpu/drm/via/via_mm.c                    |  8 ++--
 drivers/gpu/drm/virtio/virtgpu_kms.c            |  5 ++-
 drivers/gpu/drm/virtio/virtgpu_vq.c             |  5 ++-
 drivers/gpu/drm/vmwgfx/vmwgfx_resource.c        |  9 ++--
 drivers/i2c/i2c-core-base.c                     | 19 +++++----
 drivers/infiniband/core/cm.c                    |  8 ++--
 drivers/infiniband/core/cma.c                   | 12 +++---
 drivers/infiniband/core/rdma_core.c             |  9 ++--
 drivers/infiniband/core/sa_query.c              | 23 +++++-----
 drivers/infiniband/core/ucm.c                   |  7 ++-
 drivers/infiniband/core/ucma.c                  | 14 ++++--
 drivers/infiniband/hw/cxgb3/iwch.c              |  4 +-
 drivers/infiniband/hw/cxgb3/iwch.h              |  4 +-
 drivers/infiniband/hw/cxgb4/device.c            | 18 ++++----
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |  4 +-
 drivers/infiniband/hw/hfi1/init.c               |  9 ++--
 drivers/infiniband/hw/hfi1/vnic_main.c          |  6 +--
 drivers/infiniband/hw/mlx4/cm.c                 | 13 +++---
 drivers/infiniband/hw/ocrdma/ocrdma_main.c      |  7 ++-
 drivers/infiniband/hw/qib/qib_init.c            |  9 ++--
 drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c | 10 ++---
 drivers/iommu/intel-svm.c                       |  9 ++--
 drivers/md/dm.c                                 | 13 +++---
 drivers/memstick/core/memstick.c                | 10 +++--
 drivers/memstick/core/ms_block.c                |  9 ++--
 drivers/memstick/core/mspro_block.c             | 12 ++++--
 drivers/mfd/rtsx_pcr.c                          |  9 ++--
 drivers/misc/c2port/core.c                      |  7 +--
 drivers/misc/cxl/context.c                      |  8 ++--
 drivers/misc/cxl/main.c                         | 15 ++++---
 drivers/misc/mei/main.c                         |  8 ++--
 drivers/misc/mic/scif/scif_api.c                | 11 ++---
 drivers/misc/mic/scif/scif_ports.c              | 18 ++++----
 drivers/misc/tifm_core.c                        |  9 ++--
 drivers/mtd/mtdcore.c                           |  9 ++--
 drivers/mtd/mtdcore.h                           |  2 +-
 drivers/mtd/ubi/block.c                         |  7 ++-
 drivers/net/ppp/ppp_generic.c                   | 27 ++++++------
 drivers/net/tap.c                               | 10 +++--
 drivers/net/wireless/ath/ath10k/htt.h           |  3 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c        | 22 ++++++----
 drivers/net/wireless/ath/ath10k/mac.c           |  2 +-
 drivers/net/wireless/marvell/mwifiex/main.c     | 13 +++---
 drivers/net/wireless/marvell/mwifiex/wmm.c      |  2 +-
 drivers/of/overlay.c                            | 15 +++----
 drivers/of/unittest.c                           | 25 ++++++-----
 drivers/power/supply/bq2415x_charger.c          | 16 +++----
 drivers/power/supply/bq27xxx_battery_i2c.c      | 15 ++++---
 drivers/power/supply/ds2782_battery.c           |  9 ++--
 drivers/powercap/powercap_sys.c                 |  8 ++--
 drivers/pps/pps.c                               | 10 +++--
 drivers/rapidio/rio_cm.c                        | 17 ++++----
 drivers/remoteproc/remoteproc_core.c            |  8 ++--
 drivers/rpmsg/virtio_rpmsg_bus.c                |  8 ++--
 drivers/scsi/bfa/bfad_im.c                      |  8 ++--
 drivers/scsi/ch.c                               |  8 ++--
 drivers/scsi/lpfc/lpfc_crtn.h                   |  2 +-
 drivers/scsi/lpfc/lpfc_init.c                   | 11 +++--
 drivers/scsi/lpfc/lpfc_vport.c                  |  8 ++--
 drivers/scsi/sg.c                               | 10 +++--
 drivers/scsi/st.c                               |  8 ++--
 drivers/staging/greybus/uart.c                  | 22 +++++-----
 drivers/staging/unisys/visorhba/visorhba_main.c |  7 +--
 drivers/target/iscsi/iscsi_target.c             |  7 +--
 drivers/target/iscsi/iscsi_target_login.c       |  9 ++--
 drivers/target/target_core_device.c             |  9 ++--
 drivers/target/target_core_user.c               | 13 +++---
 drivers/tee/tee_shm.c                           |  8 ++--
 drivers/uio/uio.c                               |  9 ++--
 drivers/usb/class/cdc-acm.c                     | 24 ++++++-----
 drivers/usb/core/devices.c                      |  2 +-
 drivers/usb/core/hcd.c                          |  7 +--
 drivers/usb/mon/mon_main.c                      |  3 +-
 drivers/usb/serial/usb-serial.c                 | 11 ++---
 drivers/vfio/vfio.c                             | 15 ++++---
 fs/dlm/lock.c                                   |  9 ++--
 fs/dlm/lockspace.c                              |  6 +--
 fs/dlm/recover.c                                | 10 ++---
 fs/nfs/nfs4client.c                             |  9 ++--
 fs/nfsd/nfs4state.c                             |  8 ++--
 fs/notify/inotify/inotify_fsnotify.c            |  4 +-
 fs/notify/inotify/inotify_user.c                |  9 ++--
 fs/ocfs2/cluster/tcp.c                          | 10 +++--
 include/linux/idr.h                             | 26 +++++------
 include/linux/of.h                              |  4 +-
 include/linux/radix-tree.h                      |  2 +-
 include/net/9p/9p.h                             |  2 +-
 ipc/msg.c                                       |  2 +-
 ipc/sem.c                                       |  2 +-
 ipc/shm.c                                       |  4 +-
 ipc/util.c                                      | 17 ++++----
 kernel/bpf/syscall.c                            | 20 +++++----
 kernel/cgroup/cgroup.c                          | 57 +++++++++++++++----------
 kernel/events/core.c                            | 10 ++---
 kernel/workqueue.c                              | 15 ++++---
 lib/idr.c                                       | 38 ++++++++++-------
 lib/radix-tree.c                                |  5 ++-
 mm/memcontrol.c                                 | 11 +++--
 net/9p/client.c                                 | 17 ++++----
 net/9p/util.c                                   | 14 +++---
 net/core/net_namespace.c                        | 23 +++++-----
 net/mac80211/cfg.c                              | 23 +++++-----
 net/mac80211/iface.c                            |  3 +-
 net/mac80211/main.c                             |  2 +-
 net/mac80211/tx.c                               |  7 +--
 net/mac80211/util.c                             |  3 +-
 net/netlink/genetlink.c                         | 18 ++++----
 net/qrtr/qrtr.c                                 | 21 +++++----
 net/rxrpc/conn_client.c                         | 15 ++++---
 net/sctp/associola.c                            |  8 ++--
 net/tipc/server.c                               |  7 +--
 153 files changed, 956 insertions(+), 736 deletions(-)

diff --git a/block/bsg.c b/block/bsg.c
index 37663b6..c2969af 100644
--- a/block/bsg.c
+++ b/block/bsg.c
@@ -981,6 +981,7 @@ int bsg_register_queue(struct request_queue *q, struct device *parent,
 	int ret;
 	struct device *class_dev = NULL;
 	const char *devname;
+	unsigned long idr_index;
 
 	if (name)
 		devname = name;
@@ -998,8 +999,9 @@ int bsg_register_queue(struct request_queue *q, struct device *parent,
 
 	mutex_lock(&bsg_mutex);
 
-	ret = idr_alloc(&bsg_minor_idr, bcd, 0, BSG_MAX_DEVS, GFP_KERNEL);
-	if (ret < 0) {
+	ret = idr_alloc(&bsg_minor_idr, bcd, &idr_index, 0, BSG_MAX_DEVS,
+			GFP_KERNEL);
+	if (ret) {
 		if (ret == -ENOSPC) {
 			printk(KERN_ERR "bsg: too many bsg devices\n");
 			ret = -EINVAL;
@@ -1007,7 +1009,7 @@ int bsg_register_queue(struct request_queue *q, struct device *parent,
 		goto unlock;
 	}
 
-	bcd->minor = ret;
+	bcd->minor = idr_index;
 	bcd->queue = q;
 	bcd->parent = get_device(parent);
 	bcd->release = release;
diff --git a/block/genhd.c b/block/genhd.c
index 7f520fa..1f7d7c3 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -414,7 +414,8 @@ static int blk_mangle_minor(int minor)
 int blk_alloc_devt(struct hd_struct *part, dev_t *devt)
 {
 	struct gendisk *disk = part_to_disk(part);
-	int idx;
+	unsigned long idr_index;
+	int ret;
 
 	/* in consecutive minor range? */
 	if (part->partno < disk->minors) {
@@ -426,14 +427,15 @@ int blk_alloc_devt(struct hd_struct *part, dev_t *devt)
 	idr_preload(GFP_KERNEL);
 
 	spin_lock_bh(&ext_devt_lock);
-	idx = idr_alloc(&ext_devt_idr, part, 0, NR_EXT_DEVT, GFP_NOWAIT);
+	ret = idr_alloc(&ext_devt_idr, part, &idr_index, 0, NR_EXT_DEVT,
+			GFP_NOWAIT);
 	spin_unlock_bh(&ext_devt_lock);
 
 	idr_preload_end();
-	if (idx < 0)
-		return idx == -ENOSPC ? -EBUSY : idx;
+	if (ret)
+		return ret == -ENOSPC ? -EBUSY : ret;
 
-	*devt = MKDEV(BLOCK_EXT_MAJOR, blk_mangle_minor(idx));
+	*devt = MKDEV(BLOCK_EXT_MAJOR, blk_mangle_minor(idr_index));
 	return 0;
 }
 
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index a970283..92b9ba5 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -943,7 +943,8 @@ static void free_scq(ns_dev *card, scq_info *scq, struct atm_vcc *vcc)
 static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 {
 	struct sk_buff *handle1, *handle2;
-	int id1, id2;
+	int ret;
+	unsigned long id1, id2;
 	u32 addr1, addr2;
 	u32 stat;
 	unsigned long flags;
@@ -1019,12 +1020,12 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 				card->lbfqc += 2;
 		}
 
-		id1 = idr_alloc(&card->idr, handle1, 0, 0, GFP_ATOMIC);
-		if (id1 < 0)
+		ret = idr_alloc(&card->idr, handle1, &id1, 0, 0, GFP_ATOMIC);
+		if (ret)
 			goto out;
 
-		id2 = idr_alloc(&card->idr, handle2, 0, 0, GFP_ATOMIC);
-		if (id2 < 0)
+		ret = idr_alloc(&card->idr, handle2, &id2, 0, 0, GFP_ATOMIC);
+		if (ret)
 			goto out;
 
 		spin_lock_irqsave(&card->res_lock, flags);
diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index e2ed28d..4ee5a91 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -489,7 +489,8 @@ void _drbd_thread_stop(struct drbd_thread *thi, int restart, int wait)
 int conn_lowest_minor(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
-	int vnr = 0, minor = -1;
+	int minor = -1;
+	unsigned long vnr = 0;
 
 	rcu_read_lock();
 	peer_device = idr_get_next(&connection->peer_devices, &vnr);
@@ -2390,7 +2391,7 @@ void drbd_free_resource(struct drbd_resource *resource)
 
 static void drbd_cleanup(void)
 {
-	unsigned int i;
+	unsigned long i;
 	struct drbd_device *device;
 	struct drbd_resource *resource, *tmp;
 
@@ -2794,7 +2795,8 @@ enum drbd_ret_code drbd_create_device(struct drbd_config_context *adm_ctx, unsig
 	struct drbd_peer_device *peer_device, *tmp_peer_device;
 	struct gendisk *disk;
 	struct request_queue *q;
-	int id;
+	int ret;
+	unsigned long idr_index;
 	int vnr = adm_ctx->volume;
 	enum drbd_ret_code err = ERR_NOMEM;
 
@@ -2858,17 +2860,19 @@ enum drbd_ret_code drbd_create_device(struct drbd_config_context *adm_ctx, unsig
 	device->read_requests = RB_ROOT;
 	device->write_requests = RB_ROOT;
 
-	id = idr_alloc(&drbd_devices, device, minor, minor + 1, GFP_KERNEL);
-	if (id < 0) {
-		if (id == -ENOSPC)
+	ret = idr_alloc(&drbd_devices, device, &idr_index, minor, minor + 1,
+			GFP_KERNEL);
+	if (ret) {
+		if (ret == -ENOSPC)
 			err = ERR_MINOR_OR_VOLUME_EXISTS;
 		goto out_no_minor_idr;
 	}
 	kref_get(&device->kref);
 
-	id = idr_alloc(&resource->devices, device, vnr, vnr + 1, GFP_KERNEL);
-	if (id < 0) {
-		if (id == -ENOSPC)
+	ret = idr_alloc(&resource->devices, device, &idr_index, vnr, vnr + 1,
+			GFP_KERNEL);
+	if (ret) {
+		if (ret == -ENOSPC)
 			err = ERR_MINOR_OR_VOLUME_EXISTS;
 		goto out_idr_remove_minor;
 	}
@@ -2886,9 +2890,10 @@ enum drbd_ret_code drbd_create_device(struct drbd_config_context *adm_ctx, unsig
 		list_add(&peer_device->peer_devices, &device->peer_devices);
 		kref_get(&device->kref);
 
-		id = idr_alloc(&connection->peer_devices, peer_device, vnr, vnr + 1, GFP_KERNEL);
-		if (id < 0) {
-			if (id == -ENOSPC)
+		ret = idr_alloc(&connection->peer_devices, peer_device,
+				&idr_index, vnr, vnr + 1, GFP_KERNEL);
+		if (ret) {
+			if (ret == -ENOSPC)
 				err = ERR_INVALID_REQUEST;
 			goto out_idr_remove_from_resource;
 		}
@@ -3072,7 +3077,7 @@ void drbd_free_sock(struct drbd_connection *connection)
 void conn_md_sync(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index ad0fcb4..913adf5 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -428,7 +428,7 @@ static enum drbd_fencing_p highest_fencing_policy(struct drbd_connection *connec
 {
 	enum drbd_fencing_p fp = FP_NOT_AVAIL;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -2209,7 +2209,7 @@ static bool conn_resync_running(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
 	bool rv = false;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -2231,7 +2231,7 @@ static bool conn_ov_running(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
 	bool rv = false;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -2251,7 +2251,7 @@ static bool conn_ov_running(struct drbd_connection *connection)
 _check_net_options(struct drbd_connection *connection, struct net_conf *old_net_conf, struct net_conf *new_net_conf)
 {
 	struct drbd_peer_device *peer_device;
-	int i;
+	unsigned long i;
 
 	if (old_net_conf && connection->cstate == C_WF_REPORT_PARAMS && connection->agreed_pro_version < 100) {
 		if (new_net_conf->wire_protocol != old_net_conf->wire_protocol)
@@ -2488,7 +2488,7 @@ int drbd_adm_net_opts(struct sk_buff *skb, struct genl_info *info)
 
 	if (connection->cstate >= C_WF_REPORT_PARAMS) {
 		struct drbd_peer_device *peer_device;
-		int vnr;
+		unsigned long vnr;
 
 		idr_for_each_entry(&connection->peer_devices, peer_device, vnr)
 			drbd_send_sync_param(peer_device);
@@ -2542,7 +2542,7 @@ int drbd_adm_connect(struct sk_buff *skb, struct genl_info *info)
 	struct drbd_resource *resource;
 	struct drbd_connection *connection;
 	enum drbd_ret_code retcode;
-	int i;
+	unsigned long i;
 	int err;
 
 	retcode = drbd_adm_prepare(&adm_ctx, skb, info, DRBD_ADM_NEED_RESOURCE);
@@ -3382,7 +3382,8 @@ int drbd_adm_dump_devices(struct sk_buff *skb, struct netlink_callback *cb)
 	struct nlattr *resource_filter;
 	struct drbd_resource *resource;
 	struct drbd_device *uninitialized_var(device);
-	int minor, err, retcode;
+	int err, retcode;
+	unsigned long minor;
 	struct drbd_genlmsghdr *dh;
 	struct device_info device_info;
 	struct device_statistics device_statistics;
@@ -3634,7 +3635,8 @@ int drbd_adm_dump_peer_devices(struct sk_buff *skb, struct netlink_callback *cb)
 	struct drbd_resource *resource;
 	struct drbd_device *uninitialized_var(device);
 	struct drbd_peer_device *peer_device = NULL;
-	int minor, err, retcode;
+	int err, retcode;
+	unsigned long minor;
 	struct drbd_genlmsghdr *dh;
 	struct idr *idr_to_search;
 
@@ -3887,7 +3889,7 @@ static int get_one_status(struct sk_buff *skb, struct netlink_callback *cb)
 	struct drbd_resource *pos = (struct drbd_resource *)cb->args[0];
 	struct drbd_resource *resource = NULL;
 	struct drbd_resource *tmp;
-	unsigned volume = cb->args[1];
+	unsigned long volume = cb->args[1];
 
 	/* Open coded, deferred, iteration:
 	 * for_each_resource_safe(resource, tmp, &drbd_resources) {
@@ -4464,7 +4466,7 @@ int drbd_adm_down(struct sk_buff *skb, struct genl_info *info)
 	struct drbd_connection *connection;
 	struct drbd_device *device;
 	int retcode; /* enum drbd_ret_code rsp. enum drbd_state_rv */
-	unsigned i;
+	unsigned long i;
 
 	retcode = drbd_adm_prepare(&adm_ctx, skb, info, DRBD_ADM_NEED_RESOURCE);
 	if (!adm_ctx.reply_skb)
diff --git a/drivers/block/drbd/drbd_proc.c b/drivers/block/drbd/drbd_proc.c
index 8378142..1c9c5b8 100644
--- a/drivers/block/drbd/drbd_proc.c
+++ b/drivers/block/drbd/drbd_proc.c
@@ -237,7 +237,8 @@ static void drbd_syncer_progress(struct drbd_device *device, struct seq_file *se
 
 static int drbd_seq_show(struct seq_file *seq, void *v)
 {
-	int i, prev_i = -1;
+	int prev_i = -1;
+	unsigned long i;
 	const char *sn;
 	struct drbd_device *device;
 	struct net_conf *nc;
diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index c7e95e6..64ab66e 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -232,7 +232,7 @@ static void drbd_reclaim_net_peer_reqs(struct drbd_device *device)
 static void conn_reclaim_net_peer_reqs(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -934,7 +934,8 @@ static int conn_connect(struct drbd_connection *connection)
 	struct drbd_socket sock, msock;
 	struct drbd_peer_device *peer_device;
 	struct net_conf *nc;
-	int vnr, timeout, h;
+	int timeout, h;
+	unsigned long vnr;
 	bool discard_my_data, ok;
 	enum drbd_state_rv rv;
 	struct accept_wait_data ad = {
@@ -1281,7 +1282,7 @@ static void drbd_flush(struct drbd_connection *connection)
 	if (connection->resource->write_ordering >= WO_BDEV_FLUSH) {
 		struct drbd_peer_device *peer_device;
 		struct issue_flush_context ctx;
-		int vnr;
+		unsigned long vnr;
 
 		atomic_set(&ctx.pending, 1);
 		ctx.error = 0;
@@ -1418,7 +1419,7 @@ void drbd_bump_write_ordering(struct drbd_resource *resource, struct drbd_backin
 {
 	struct drbd_device *device;
 	enum write_ordering_e pwo;
-	int vnr;
+	unsigned long vnr;
 	static char *write_ordering_str[] = {
 		[WO_NONE] = "none",
 		[WO_DRAIN_IO] = "drain",
@@ -1606,7 +1607,7 @@ static void drbd_remove_epoch_entry_interval(struct drbd_device *device,
 static void conn_wait_active_ee_empty(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -4933,7 +4934,7 @@ static void conn_disconnect(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
 	enum drbd_conns oc;
-	int vnr;
+	unsigned long vnr;
 
 	if (connection->cstate == C_STANDALONE)
 		return;
@@ -5644,7 +5645,7 @@ static int got_BarrierAck(struct drbd_connection *connection, struct packet_info
 {
 	struct p_barrier_ack *p = pi->data;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	tl_release(connection, p->barrier, be32_to_cpu(p->set_size));
 
diff --git a/drivers/block/drbd/drbd_state.c b/drivers/block/drbd/drbd_state.c
index eea0c4a..d6566d0 100644
--- a/drivers/block/drbd/drbd_state.c
+++ b/drivers/block/drbd/drbd_state.c
@@ -56,7 +56,7 @@ static void count_objects(struct drbd_resource *resource,
 {
 	struct drbd_device *device;
 	struct drbd_connection *connection;
-	int vnr;
+	unsigned long vnr;
 
 	*n_devices = 0;
 	*n_connections = 0;
@@ -99,7 +99,7 @@ struct drbd_state_change *remember_old_state(struct drbd_resource *resource, gfp
 	unsigned int n_devices;
 	struct drbd_connection *connection;
 	unsigned int n_connections;
-	int vnr;
+	unsigned long vnr;
 
 	struct drbd_device_state_change *device_state_change;
 	struct drbd_peer_device_state_change *peer_device_state_change;
@@ -307,7 +307,7 @@ bool conn_all_vols_unconf(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
 	bool rv = true;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -348,7 +348,7 @@ enum drbd_role conn_highest_role(struct drbd_connection *connection)
 {
 	enum drbd_role role = R_UNKNOWN;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -364,7 +364,7 @@ enum drbd_role conn_highest_peer(struct drbd_connection *connection)
 {
 	enum drbd_role peer = R_UNKNOWN;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -380,7 +380,7 @@ enum drbd_disk_state conn_highest_disk(struct drbd_connection *connection)
 {
 	enum drbd_disk_state disk_state = D_DISKLESS;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -396,7 +396,7 @@ enum drbd_disk_state conn_lowest_disk(struct drbd_connection *connection)
 {
 	enum drbd_disk_state disk_state = D_MASK;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -412,7 +412,7 @@ enum drbd_disk_state conn_highest_pdsk(struct drbd_connection *connection)
 {
 	enum drbd_disk_state disk_state = D_DISKLESS;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -428,7 +428,7 @@ enum drbd_conns conn_lowest_conn(struct drbd_connection *connection)
 {
 	enum drbd_conns conn = C_MASK;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -443,7 +443,7 @@ enum drbd_conns conn_lowest_conn(struct drbd_connection *connection)
 static bool no_peer_wf_report_params(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 	bool rv = true;
 
 	rcu_read_lock();
@@ -460,7 +460,7 @@ static bool no_peer_wf_report_params(struct drbd_connection *connection)
 static void wake_up_all_devices(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr)
@@ -1723,7 +1723,7 @@ static void after_state_ch(struct drbd_device *device, union drbd_state os,
 		if (resource->susp_fen && conn_lowest_conn(connection) >= C_CONNECTED) {
 			/* case2: The connection was established again: */
 			struct drbd_peer_device *peer_device;
-			int vnr;
+			unsigned long vnr;
 
 			rcu_read_lock();
 			idr_for_each_entry(&connection->peer_devices, peer_device, vnr)
@@ -2010,7 +2010,7 @@ static int w_after_conn_state_ch(struct drbd_work *w, int unused)
 	enum drbd_conns oc = acscw->oc;
 	union drbd_state ns_max = acscw->ns_max;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	broadcast_state_change(acscw->state_change);
 	forget_state_change(acscw->state_change);
@@ -2074,7 +2074,8 @@ static void conn_old_common_state(struct drbd_connection *connection, union drbd
 {
 	enum chg_state_flags flags = ~0;
 	struct drbd_peer_device *peer_device;
-	int vnr, first_vol = 1;
+	int first_vol = 1;
+	unsigned long vnr;
 	union drbd_dev_state os, cs = {
 		{ .role = R_SECONDARY,
 		  .peer = R_UNKNOWN,
@@ -2123,7 +2124,7 @@ static void conn_old_common_state(struct drbd_connection *connection, union drbd
 	enum drbd_state_rv rv = SS_SUCCESS;
 	union drbd_state ns, os;
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -2173,7 +2174,8 @@ static void conn_old_common_state(struct drbd_connection *connection, union drbd
 		} };
 	struct drbd_peer_device *peer_device;
 	enum drbd_state_rv rv;
-	int vnr, number_of_volumes = 0;
+	int number_of_volumes = 0;
+	unsigned long vnr;
 
 	if (mask.conn == C_MASK) {
 		/* remember last connect time so request_timer_fn() won't
diff --git a/drivers/block/drbd/drbd_worker.c b/drivers/block/drbd/drbd_worker.c
index 1d8726a..8129b00 100644
--- a/drivers/block/drbd/drbd_worker.c
+++ b/drivers/block/drbd/drbd_worker.c
@@ -1553,7 +1553,7 @@ static bool drbd_pause_after(struct drbd_device *device)
 {
 	bool changed = false;
 	struct drbd_device *odev;
-	int i;
+	unsigned long i;
 
 	rcu_read_lock();
 	idr_for_each_entry(&drbd_devices, odev, i) {
@@ -2035,7 +2035,7 @@ static unsigned long get_work_bits(unsigned long *flags)
 static void do_unqueued_work(struct drbd_connection *connection)
 {
 	struct drbd_peer_device *peer_device;
-	int vnr;
+	unsigned long vnr;
 
 	rcu_read_lock();
 	idr_for_each_entry(&connection->peer_devices, peer_device, vnr) {
@@ -2152,7 +2152,7 @@ int drbd_worker(struct drbd_thread *thi)
 	struct drbd_work *w = NULL;
 	struct drbd_peer_device *peer_device;
 	LIST_HEAD(work_list);
-	int vnr;
+	unsigned long vnr;
 
 	while (get_t_state(thi) == RUNNING) {
 		drbd_thread_current_set_cpu(thi);
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index ef83349..6308b44 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -1655,7 +1655,7 @@ int loop_register_transfer(struct loop_func_table *funcs)
 	return 0;
 }
 
-static int unregister_transfer_cb(int id, void *ptr, void *data)
+static int unregister_transfer_cb(unsigned long id, void *ptr, void *data)
 {
 	struct loop_device *lo = ptr;
 	struct loop_func_table *xfer = data;
@@ -1759,6 +1759,7 @@ static int loop_add(struct loop_device **l, int i)
 {
 	struct loop_device *lo;
 	struct gendisk *disk;
+	unsigned long idr_index;
 	int err;
 
 	err = -ENOMEM;
@@ -1770,15 +1771,17 @@ static int loop_add(struct loop_device **l, int i)
 
 	/* allocate id, if @id >= 0, we're requesting that specific id */
 	if (i >= 0) {
-		err = idr_alloc(&loop_index_idr, lo, i, i + 1, GFP_KERNEL);
+		err = idr_alloc(&loop_index_idr, lo, &idr_index, i, i + 1,
+				GFP_KERNEL);
 		if (err == -ENOSPC)
 			err = -EEXIST;
 	} else {
-		err = idr_alloc(&loop_index_idr, lo, 0, 0, GFP_KERNEL);
+		err = idr_alloc(&loop_index_idr, lo, &idr_index, 0, 0,
+				GFP_KERNEL);
 	}
-	if (err < 0)
+	if (err)
 		goto out_free_dev;
-	i = err;
+	i = idr_index;
 
 	err = -ENOMEM;
 	lo->tag_set.ops = &loop_mq_ops;
@@ -1867,7 +1870,7 @@ static void loop_remove(struct loop_device *lo)
 	kfree(lo);
 }
 
-static int find_free_cb(int id, void *ptr, void *data)
+static int find_free_cb(unsigned long id, void *ptr, void *data)
 {
 	struct loop_device *lo = ptr;
 	struct loop_device **l = data;
@@ -2063,7 +2066,7 @@ static int __init loop_init(void)
 	return err;
 }
 
-static int loop_exit_cb(int id, void *ptr, void *data)
+static int loop_exit_cb(unsigned long id, void *ptr, void *data)
 {
 	struct loop_device *lo = ptr;
 
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 5bdf923..f55b695 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -1427,6 +1427,7 @@ static int nbd_dev_add(int index)
 	struct nbd_device *nbd;
 	struct gendisk *disk;
 	struct request_queue *q;
+	unsigned long idr_index;
 	int err = -ENOMEM;
 
 	nbd = kzalloc(sizeof(struct nbd_device), GFP_KERNEL);
@@ -1438,16 +1439,17 @@ static int nbd_dev_add(int index)
 		goto out_free_nbd;
 
 	if (index >= 0) {
-		err = idr_alloc(&nbd_index_idr, nbd, index, index + 1,
-				GFP_KERNEL);
+		err = idr_alloc(&nbd_index_idr, nbd, &idr_index,
+				index, index + 1, GFP_KERNEL);
 		if (err == -ENOSPC)
 			err = -EEXIST;
 	} else {
-		err = idr_alloc(&nbd_index_idr, nbd, 0, 0, GFP_KERNEL);
-		if (err >= 0)
-			index = err;
+		err = idr_alloc(&nbd_index_idr, nbd, &idr_index,
+				0, 0, GFP_KERNEL);
+		if (err == 0)
+			index = idr_index;
 	}
-	if (err < 0)
+	if (err)
 		goto out_free_disk;
 
 	nbd->index = index;
@@ -1509,7 +1511,7 @@ static int nbd_dev_add(int index)
 	return err;
 }
 
-static int find_free_cb(int id, void *ptr, void *data)
+static int find_free_cb(unsigned long id, void *ptr, void *data)
 {
 	struct nbd_device *nbd = ptr;
 	struct nbd_device **found = data;
@@ -1922,7 +1924,7 @@ static int populate_nbd_status(struct nbd_device *nbd, struct sk_buff *reply)
 	return 0;
 }
 
-static int status_cb(int id, void *ptr, void *data)
+static int status_cb(unsigned long id, void *ptr, void *data)
 {
 	struct nbd_device *nbd = ptr;
 	return populate_nbd_status(nbd, (struct sk_buff *)data);
@@ -2094,7 +2096,7 @@ static int __init nbd_init(void)
 	return 0;
 }
 
-static int nbd_exit_cb(int id, void *ptr, void *data)
+static int nbd_exit_cb(unsigned long id, void *ptr, void *data)
 {
 	struct list_head *list = (struct list_head *)data;
 	struct nbd_device *nbd = ptr;
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 856d5dc02..7b4d9fb 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1137,15 +1137,16 @@ static int zram_add(void)
 	struct zram *zram;
 	struct request_queue *queue;
 	int ret, device_id;
+	unsigned long idr_index;
 
 	zram = kzalloc(sizeof(struct zram), GFP_KERNEL);
 	if (!zram)
 		return -ENOMEM;
 
-	ret = idr_alloc(&zram_index_idr, zram, 0, 0, GFP_KERNEL);
-	if (ret < 0)
+	ret = idr_alloc(&zram_index_idr, zram, &idr_index, 0, 0, GFP_KERNEL);
+	if (ret)
 		goto out_free_dev;
-	device_id = ret;
+	device_id = idr_index;
 
 	init_rwsem(&zram->init_lock);
 
@@ -1341,7 +1342,7 @@ static ssize_t hot_remove_store(struct class *class,
 	.class_groups	= zram_control_class_groups,
 };
 
-static int zram_remove_cb(int id, void *ptr, void *data)
+static int zram_remove_cb(unsigned long id, void *ptr, void *data)
 {
 	zram_remove(ptr);
 	return 0;
diff --git a/drivers/char/tpm/tpm-chip.c b/drivers/char/tpm/tpm-chip.c
index 67ec9d3..70cea3c 100644
--- a/drivers/char/tpm/tpm-chip.c
+++ b/drivers/char/tpm/tpm-chip.c
@@ -86,7 +86,7 @@ void tpm_put_ops(struct tpm_chip *chip)
  * The return'd chip has been tpm_try_get_ops'd and must be released via
  * tpm_put_ops
  */
-struct tpm_chip *tpm_chip_find_get(int chip_num)
+struct tpm_chip *tpm_chip_find_get(unsigned long chip_num)
 {
 	struct tpm_chip *chip, *res = NULL;
 	int chip_prev;
@@ -189,6 +189,7 @@ struct tpm_chip *tpm_chip_alloc(struct device *pdev,
 				const struct tpm_class_ops *ops)
 {
 	struct tpm_chip *chip;
+	unsigned long idr_index;
 	int rc;
 
 	chip = kzalloc(sizeof(*chip), GFP_KERNEL);
@@ -201,14 +202,15 @@ struct tpm_chip *tpm_chip_alloc(struct device *pdev,
 	chip->ops = ops;
 
 	mutex_lock(&idr_lock);
-	rc = idr_alloc(&dev_nums_idr, NULL, 0, TPM_NUM_DEVICES, GFP_KERNEL);
+	rc = idr_alloc(&dev_nums_idr, NULL, &idr_index, 0, TPM_NUM_DEVICES,
+		       GFP_KERNEL);
 	mutex_unlock(&idr_lock);
-	if (rc < 0) {
+	if (rc) {
 		dev_err(pdev, "No available tpm device numbers\n");
 		kfree(chip);
 		return ERR_PTR(rc);
 	}
-	chip->dev_num = rc;
+	chip->dev_num = idr_index;
 
 	device_initialize(&chip->dev);
 	device_initialize(&chip->devs);
diff --git a/drivers/char/tpm/tpm.h b/drivers/char/tpm/tpm.h
index 04fbff2..5e6538b 100644
--- a/drivers/char/tpm/tpm.h
+++ b/drivers/char/tpm/tpm.h
@@ -527,7 +527,7 @@ ssize_t tpm_getcap(struct tpm_chip *chip, u32 subcap_id, cap_t *cap,
 int wait_for_tpm_stat(struct tpm_chip *chip, u8 mask, unsigned long timeout,
 		      wait_queue_head_t *queue, bool check_cancel);
 
-struct tpm_chip *tpm_chip_find_get(int chip_num);
+struct tpm_chip *tpm_chip_find_get(unsigned long chip_num);
 __must_check int tpm_try_get_ops(struct tpm_chip *chip);
 void tpm_put_ops(struct tpm_chip *chip);
 
diff --git a/drivers/dca/dca-sysfs.c b/drivers/dca/dca-sysfs.c
index 126cf29..93a7798 100644
--- a/drivers/dca/dca-sysfs.c
+++ b/drivers/dca/dca-sysfs.c
@@ -53,18 +53,19 @@ void dca_sysfs_remove_req(struct dca_provider *dca, int slot)
 int dca_sysfs_add_provider(struct dca_provider *dca, struct device *dev)
 {
 	struct device *cd;
+	unsigned long idr_index;
 	int ret;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&dca_idr_lock);
 
-	ret = idr_alloc(&dca_idr, dca, 0, 0, GFP_NOWAIT);
-	if (ret >= 0)
-		dca->id = ret;
+	ret = idr_alloc(&dca_idr, dca, &idr_index, 0, 0, GFP_NOWAIT);
+	if (ret == 0)
+		dca->id = idr_index;
 
 	spin_unlock(&dca_idr_lock);
 	idr_preload_end();
-	if (ret < 0)
+	if (ret)
 		return ret;
 
 	cd = device_create(dca_class, dev, MKDEV(0, 0), NULL, "dca%d", dca->id);
diff --git a/drivers/firewire/core-cdev.c b/drivers/firewire/core-cdev.c
index a301fcf..162c2b5 100644
--- a/drivers/firewire/core-cdev.c
+++ b/drivers/firewire/core-cdev.c
@@ -378,7 +378,7 @@ static void for_each_client(struct fw_device *device,
 	mutex_unlock(&device->client_list_mutex);
 }
 
-static int schedule_reallocations(int id, void *p, void *data)
+static int schedule_reallocations(unsigned long id, void *p, void *data)
 {
 	schedule_if_iso_resource(p);
 
@@ -488,6 +488,7 @@ static int add_client_resource(struct client *client,
 {
 	bool preload = gfpflags_allow_blocking(gfp_mask);
 	unsigned long flags;
+	unsigned long idr_index;
 	int ret;
 
 	if (preload)
@@ -497,10 +498,10 @@ static int add_client_resource(struct client *client,
 	if (client->in_shutdown)
 		ret = -ECANCELED;
 	else
-		ret = idr_alloc(&client->resource_idr, resource, 0, 0,
-				GFP_NOWAIT);
-	if (ret >= 0) {
-		resource->handle = ret;
+		ret = idr_alloc(&client->resource_idr, resource, &idr_index,
+				0, 0, GFP_NOWAIT);
+	if (ret == 0) {
+		resource->handle = idr_index;
 		client_get(client);
 		schedule_if_iso_resource(resource);
 	}
@@ -509,7 +510,7 @@ static int add_client_resource(struct client *client,
 	if (preload)
 		idr_preload_end();
 
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 static int release_client_resource(struct client *client, u32 handle,
@@ -1717,7 +1718,8 @@ static int fw_device_op_mmap(struct file *file, struct vm_area_struct *vma)
 	return ret;
 }
 
-static int is_outbound_transaction_resource(int id, void *p, void *data)
+static int is_outbound_transaction_resource(unsigned long id, void *p,
+					    void *data)
 {
 	struct client_resource *resource = p;
 
@@ -1736,7 +1738,7 @@ static int has_outbound_transactions(struct client *client)
 	return ret;
 }
 
-static int shutdown_resource(int id, void *p, void *data)
+static int shutdown_resource(unsigned long id, void *p, void *data)
 {
 	struct client_resource *resource = p;
 	struct client *client = data;
diff --git a/drivers/firewire/core-device.c b/drivers/firewire/core-device.c
index 7c2eed7..2fe2e67 100644
--- a/drivers/firewire/core-device.c
+++ b/drivers/firewire/core-device.c
@@ -1000,7 +1000,8 @@ static void fw_device_init(struct work_struct *work)
 		container_of(work, struct fw_device, work.work);
 	struct fw_card *card = device->card;
 	struct device *revived_dev;
-	int minor, ret;
+	int ret;
+	unsigned long idr_index;
 
 	/*
 	 * All failure paths here set node->data to NULL, so that we
@@ -1039,18 +1040,18 @@ static void fw_device_init(struct work_struct *work)
 
 	fw_device_get(device);
 	down_write(&fw_device_rwsem);
-	minor = idr_alloc(&fw_device_idr, device, 0, 1 << MINORBITS,
-			GFP_KERNEL);
+	ret = idr_alloc(&fw_device_idr, device, &idr_index,
+			0, 1 << MINORBITS, GFP_KERNEL);
 	up_write(&fw_device_rwsem);
 
-	if (minor < 0)
+	if (ret)
 		goto error;
 
 	device->device.bus = &fw_bus_type;
 	device->device.type = &fw_device_type;
 	device->device.parent = card->device;
-	device->device.devt = MKDEV(fw_cdev_major, minor);
-	dev_set_name(&device->device, "fw%d", minor);
+	device->device.devt = MKDEV(fw_cdev_major, idr_index);
+	dev_set_name(&device->device, "fw%ld", idr_index);
 
 	BUILD_BUG_ON(ARRAY_SIZE(device->attribute_group.attrs) <
 			ARRAY_SIZE(fw_device_attributes) +
@@ -1105,7 +1106,7 @@ static void fw_device_init(struct work_struct *work)
 
  error_with_cdev:
 	down_write(&fw_device_rwsem);
-	idr_remove(&fw_device_idr, minor);
+	idr_remove(&fw_device_idr, idr_index);
 	up_write(&fw_device_rwsem);
  error:
 	fw_device_put(device);		/* fw_device_idr's reference */
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c
index 5e771bc..617e6aa 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c
@@ -62,6 +62,7 @@ static int amdgpu_bo_list_create(struct amdgpu_device *adev,
 				 int *id)
 {
 	int r;
+	unsigned long idr_index;
 	struct amdgpu_fpriv *fpriv = filp->driver_priv;
 	struct amdgpu_bo_list *list;
 
@@ -80,13 +81,14 @@ static int amdgpu_bo_list_create(struct amdgpu_device *adev,
 
 	/* idr alloc should be called only after initialization of bo list. */
 	mutex_lock(&fpriv->bo_list_lock);
-	r = idr_alloc(&fpriv->bo_list_handles, list, 1, 0, GFP_KERNEL);
+	r = idr_alloc(&fpriv->bo_list_handles, list, &idr_index, 1, 0,
+		      GFP_KERNEL);
 	mutex_unlock(&fpriv->bo_list_lock);
-	if (r < 0) {
+	if (r) {
 		kfree(list);
 		return r;
 	}
-	*id = r;
+	*id = idr_index;
 
 	return 0;
 }
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ctx.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ctx.c
index a11e443..4117764 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ctx.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ctx.c
@@ -104,6 +104,7 @@ static int amdgpu_ctx_alloc(struct amdgpu_device *adev,
 {
 	struct amdgpu_ctx_mgr *mgr = &fpriv->ctx_mgr;
 	struct amdgpu_ctx *ctx;
+	unsigned long idr_index;
 	int r;
 
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
@@ -111,13 +112,13 @@ static int amdgpu_ctx_alloc(struct amdgpu_device *adev,
 		return -ENOMEM;
 
 	mutex_lock(&mgr->lock);
-	r = idr_alloc(&mgr->ctx_handles, ctx, 1, 0, GFP_KERNEL);
-	if (r < 0) {
+	r = idr_alloc(&mgr->ctx_handles, ctx, &idr_index, 1, 0, GFP_KERNEL);
+	if (r) {
 		mutex_unlock(&mgr->lock);
 		kfree(ctx);
 		return r;
 	}
-	*id = (uint32_t)r;
+	*id = (uint32_t)idr_index;
 	r = amdgpu_ctx_init(adev, ctx);
 	if (r) {
 		idr_remove(&mgr->ctx_handles, *id);
@@ -313,7 +314,7 @@ void amdgpu_ctx_mgr_fini(struct amdgpu_ctx_mgr *mgr)
 {
 	struct amdgpu_ctx *ctx;
 	struct idr *idp;
-	uint32_t id;
+	unsigned long id;
 
 	idp = &mgr->ctx_handles;
 
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index 621f739..698a0b1 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -97,7 +97,7 @@ void amdgpu_gem_force_release(struct amdgpu_device *adev)
 
 	list_for_each_entry(file, &ddev->filelist, lhead) {
 		struct drm_gem_object *gobj;
-		int handle;
+		unsigned long handle;
 
 		WARN_ONCE(1, "Still active user space clients!\n");
 		spin_lock(&file->table_lock);
@@ -775,7 +775,7 @@ int amdgpu_mode_dumb_create(struct drm_file *file_priv,
 }
 
 #if defined(CONFIG_DEBUG_FS)
-static int amdgpu_debugfs_gem_bo_info(int id, void *ptr, void *data)
+static int amdgpu_debugfs_gem_bo_info(unsigned long id, void *ptr, void *data)
 {
 	struct drm_gem_object *gobj = ptr;
 	struct amdgpu_bo *bo = gem_to_amdgpu_bo(gobj);
@@ -798,7 +798,7 @@ static int amdgpu_debugfs_gem_bo_info(int id, void *ptr, void *data)
 		placement = " CPU";
 		break;
 	}
-	seq_printf(m, "\t0x%08x: %12ld byte %s @ 0x%010Lx",
+	seq_printf(m, "\t0x%08lx: %12ld byte %s @ 0x%010llx",
 		   id, amdgpu_bo_size(bo), placement,
 		   amdgpu_bo_gpu_offset(bo));
 
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_kms.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_kms.c
index b0b2310..0074dd6 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_kms.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_kms.c
@@ -873,7 +873,7 @@ void amdgpu_driver_postclose_kms(struct drm_device *dev,
 	struct amdgpu_device *adev = dev->dev_private;
 	struct amdgpu_fpriv *fpriv = file_priv->driver_priv;
 	struct amdgpu_bo_list *list;
-	int handle;
+	unsigned long handle;
 
 	if (!fpriv)
 		return;
diff --git a/drivers/gpu/drm/drm_auth.c b/drivers/gpu/drm/drm_auth.c
index 7ff6973..345ff34 100644
--- a/drivers/gpu/drm/drm_auth.c
+++ b/drivers/gpu/drm/drm_auth.c
@@ -57,21 +57,22 @@
 int drm_getmagic(struct drm_device *dev, void *data, struct drm_file *file_priv)
 {
 	struct drm_auth *auth = data;
+	unsigned long idr_index;
 	int ret = 0;
 
 	mutex_lock(&dev->master_mutex);
 	if (!file_priv->magic) {
 		ret = idr_alloc(&file_priv->master->magic_map, file_priv,
-				1, 0, GFP_KERNEL);
-		if (ret >= 0)
-			file_priv->magic = ret;
+				&idr_index, 1, 0, GFP_KERNEL);
+		if (ret == 0)
+			file_priv->magic = idr_index;
 	}
 	auth->magic = file_priv->magic;
 	mutex_unlock(&dev->master_mutex);
 
 	DRM_DEBUG("%u\n", auth->magic);
 
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 int drm_authmagic(struct drm_device *dev, void *data,
diff --git a/drivers/gpu/drm/drm_connector.c b/drivers/gpu/drm/drm_connector.c
index 8072e6e..555a598 100644
--- a/drivers/gpu/drm/drm_connector.c
+++ b/drivers/gpu/drm/drm_connector.c
@@ -1431,7 +1431,7 @@ struct drm_tile_group *drm_mode_get_tile_group(struct drm_device *dev,
 					       char topology[8])
 {
 	struct drm_tile_group *tg;
-	int id;
+	unsigned long id;
 	mutex_lock(&dev->mode_config.idr_mutex);
 	idr_for_each_entry(&dev->mode_config.tile_idr, tg, id) {
 		if (!memcmp(tg->group_data, topology, 8)) {
@@ -1461,6 +1461,7 @@ struct drm_tile_group *drm_mode_create_tile_group(struct drm_device *dev,
 						  char topology[8])
 {
 	struct drm_tile_group *tg;
+	unsigned long idr_index;
 	int ret;
 
 	tg = kzalloc(sizeof(*tg), GFP_KERNEL);
@@ -1472,9 +1473,10 @@ struct drm_tile_group *drm_mode_create_tile_group(struct drm_device *dev,
 	tg->dev = dev;
 
 	mutex_lock(&dev->mode_config.idr_mutex);
-	ret = idr_alloc(&dev->mode_config.tile_idr, tg, 1, 0, GFP_KERNEL);
-	if (ret >= 0) {
-		tg->id = ret;
+	ret = idr_alloc(&dev->mode_config.tile_idr, tg, &idr_index, 1, 0,
+			GFP_KERNEL);
+	if (ret == 0) {
+		tg->id = idr_index;
 	} else {
 		kfree(tg);
 		tg = ERR_PTR(ret);
diff --git a/drivers/gpu/drm/drm_context.c b/drivers/gpu/drm/drm_context.c
index 3c4000f..cc983c2 100644
--- a/drivers/gpu/drm/drm_context.c
+++ b/drivers/gpu/drm/drm_context.c
@@ -71,13 +71,14 @@ void drm_legacy_ctxbitmap_free(struct drm_device * dev, int ctx_handle)
  * Allocate a new idr from drm_device::ctx_idr while holding the
  * drm_device::struct_mutex lock.
  */
-static int drm_legacy_ctxbitmap_next(struct drm_device * dev)
+static int drm_legacy_ctxbitmap_next(struct drm_device *dev,
+				     unsigned long *handle)
 {
 	int ret;
 
 	mutex_lock(&dev->struct_mutex);
-	ret = idr_alloc(&dev->ctx_idr, NULL, DRM_RESERVED_CONTEXTS, 0,
-			GFP_KERNEL);
+	ret = idr_alloc(&dev->ctx_idr, NULL, handle,
+			DRM_RESERVED_CONTEXTS, 0, GFP_KERNEL);
 	mutex_unlock(&dev->struct_mutex);
 	return ret;
 }
@@ -361,18 +362,21 @@ int drm_legacy_addctx(struct drm_device *dev, void *data,
 {
 	struct drm_ctx_list *ctx_entry;
 	struct drm_ctx *ctx = data;
+	unsigned long handle;
+	int ret;
 
 	if (!drm_core_check_feature(dev, DRIVER_KMS_LEGACY_CONTEXT) &&
 	    !drm_core_check_feature(dev, DRIVER_LEGACY))
 		return -EINVAL;
 
-	ctx->handle = drm_legacy_ctxbitmap_next(dev);
-	if (ctx->handle == DRM_KERNEL_CONTEXT) {
+	ret = drm_legacy_ctxbitmap_next(dev, &handle);
+	if (handle == DRM_KERNEL_CONTEXT) {
 		/* Skip kernel's context and get a new one. */
-		ctx->handle = drm_legacy_ctxbitmap_next(dev);
+		ret = drm_legacy_ctxbitmap_next(dev, &handle);
 	}
-	DRM_DEBUG("%d\n", ctx->handle);
-	if (ctx->handle == -1) {
+	ctx->handle = handle;
+	DRM_DEBUG("ret: %d, handle: %u\n", ret, ctx->handle);
+	if (ret) {
 		DRM_DEBUG("Not enough free contexts.\n");
 		/* Should this return -EBUSY instead? */
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/drm_dp_aux_dev.c b/drivers/gpu/drm/drm_dp_aux_dev.c
index d34e509..89e8d16 100644
--- a/drivers/gpu/drm/drm_dp_aux_dev.c
+++ b/drivers/gpu/drm/drm_dp_aux_dev.c
@@ -70,7 +70,8 @@ static struct drm_dp_aux_dev *drm_dp_aux_dev_get_by_minor(unsigned index)
 static struct drm_dp_aux_dev *alloc_drm_dp_aux_dev(struct drm_dp_aux *aux)
 {
 	struct drm_dp_aux_dev *aux_dev;
-	int index;
+	unsigned long index;
+	int ret;
 
 	aux_dev = kzalloc(sizeof(*aux_dev), GFP_KERNEL);
 	if (!aux_dev)
@@ -80,10 +81,10 @@ static struct drm_dp_aux_dev *alloc_drm_dp_aux_dev(struct drm_dp_aux *aux)
 	kref_init(&aux_dev->refcount);
 
 	mutex_lock(&aux_idr_mutex);
-	index = idr_alloc_cyclic(&aux_idr, aux_dev, 0, DRM_AUX_MINORS,
-				 GFP_KERNEL);
+	ret = idr_alloc_cyclic(&aux_idr, aux_dev, &index, 0, DRM_AUX_MINORS,
+			       GFP_KERNEL);
 	mutex_unlock(&aux_idr_mutex);
-	if (index < 0) {
+	if (ret) {
 		kfree(aux_dev);
 		return ERR_PTR(index);
 	}
@@ -245,7 +246,7 @@ static int auxdev_release(struct inode *inode, struct file *file)
 static struct drm_dp_aux_dev *drm_dp_aux_dev_get_by_aux(struct drm_dp_aux *aux)
 {
 	struct drm_dp_aux_dev *iter, *aux_dev = NULL;
-	int id;
+	unsigned long id;
 
 	/* don't increase kref count here because this function should only be
 	 * used by drm_dp_aux_unregister_devnode. Thus, it will always have at
diff --git a/drivers/gpu/drm/drm_drv.c b/drivers/gpu/drm/drm_drv.c
index 37b8ad3..d79b8b7 100644
--- a/drivers/gpu/drm/drm_drv.c
+++ b/drivers/gpu/drm/drm_drv.c
@@ -144,6 +144,7 @@ static int drm_minor_alloc(struct drm_device *dev, unsigned int type)
 {
 	struct drm_minor *minor;
 	unsigned long flags;
+	unsigned long idr_index;
 	int r;
 
 	minor = kzalloc(sizeof(*minor), GFP_KERNEL);
@@ -157,16 +158,17 @@ static int drm_minor_alloc(struct drm_device *dev, unsigned int type)
 	spin_lock_irqsave(&drm_minor_lock, flags);
 	r = idr_alloc(&drm_minors_idr,
 		      NULL,
+		      &idr_index,
 		      64 * type,
 		      64 * (type + 1),
 		      GFP_NOWAIT);
 	spin_unlock_irqrestore(&drm_minor_lock, flags);
 	idr_preload_end();
 
-	if (r < 0)
+	if (r)
 		goto err_free;
 
-	minor->index = r;
+	minor->index = idr_index;
 
 	minor->kdev = drm_sysfs_minor_alloc(minor);
 	if (IS_ERR(minor->kdev)) {
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 8dc1106..c618333 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -249,7 +249,7 @@ static void drm_gem_object_exported_dma_buf_free(struct drm_gem_object *obj)
  * handle references on objects.
  */
 static int
-drm_gem_object_release_handle(int id, void *ptr, void *data)
+drm_gem_object_release_handle(unsigned long id, void *ptr, void *data)
 {
 	struct drm_file *file_priv = data;
 	struct drm_gem_object *obj = ptr;
@@ -347,7 +347,7 @@ int drm_gem_dumb_destroy(struct drm_file *file,
 			   u32 *handlep)
 {
 	struct drm_device *dev = obj->dev;
-	u32 handle;
+	unsigned long handle;
 	int ret;
 
 	WARN_ON(!mutex_is_locked(&dev->object_name_lock));
@@ -361,17 +361,16 @@ int drm_gem_dumb_destroy(struct drm_file *file,
 	idr_preload(GFP_KERNEL);
 	spin_lock(&file_priv->table_lock);
 
-	ret = idr_alloc(&file_priv->object_idr, obj, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc(&file_priv->object_idr, obj, &handle, 1, 0,
+			GFP_NOWAIT);
 
 	spin_unlock(&file_priv->table_lock);
 	idr_preload_end();
 
 	mutex_unlock(&dev->object_name_lock);
-	if (ret < 0)
+	if (ret)
 		goto err_unref;
 
-	handle = ret;
-
 	ret = drm_vma_node_allow(&obj->vma_node, file_priv);
 	if (ret)
 		goto err_remove;
@@ -654,6 +653,7 @@ struct drm_gem_object *
 {
 	struct drm_gem_flink *args = data;
 	struct drm_gem_object *obj;
+	unsigned long idr_index;
 	int ret;
 
 	if (!drm_core_check_feature(dev, DRIVER_GEM))
@@ -671,11 +671,12 @@ struct drm_gem_object *
 	}
 
 	if (!obj->name) {
-		ret = idr_alloc(&dev->object_name_idr, obj, 1, 0, GFP_KERNEL);
-		if (ret < 0)
+		ret = idr_alloc(&dev->object_name_idr, obj, &idr_index,
+				1, 0, GFP_KERNEL);
+		if (ret)
 			goto err;
 
-		obj->name = ret;
+		obj->name = idr_index;
 	}
 
 	args->name = (uint64_t) obj->name;
diff --git a/drivers/gpu/drm/drm_info.c b/drivers/gpu/drm/drm_info.c
index 6b68e90..5bcf144 100644
--- a/drivers/gpu/drm/drm_info.c
+++ b/drivers/gpu/drm/drm_info.c
@@ -110,7 +110,7 @@ int drm_clients_info(struct seq_file *m, void *data)
 	return 0;
 }
 
-static int drm_gem_one_name_info(int id, void *ptr, void *data)
+static int drm_gem_one_name_info(unsigned long id, void *ptr, void *data)
 {
 	struct drm_gem_object *obj = ptr;
 	struct seq_file *m = data;
diff --git a/drivers/gpu/drm/drm_mode_object.c b/drivers/gpu/drm/drm_mode_object.c
index da9a9ad..72f70bc 100644
--- a/drivers/gpu/drm/drm_mode_object.c
+++ b/drivers/gpu/drm/drm_mode_object.c
@@ -36,15 +36,18 @@ int __drm_mode_object_add(struct drm_device *dev, struct drm_mode_object *obj,
 			  void (*obj_free_cb)(struct kref *kref))
 {
 	int ret;
+	unsigned long idr_index;
 
 	mutex_lock(&dev->mode_config.idr_mutex);
-	ret = idr_alloc(&dev->mode_config.crtc_idr, register_obj ? obj : NULL, 1, 0, GFP_KERNEL);
-	if (ret >= 0) {
+	ret = idr_alloc(&dev->mode_config.crtc_idr,
+			register_obj ? obj : NULL, &idr_index, 1, 0,
+			GFP_KERNEL);
+	if (ret == 0) {
 		/*
 		 * Set up the object linking under the protection of the idr
 		 * lock so that other users can't see inconsistent state.
 		 */
-		obj->id = ret;
+		obj->id = idr_index;
 		obj->type = obj_type;
 		if (obj_free_cb) {
 			obj->free_cb = obj_free_cb;
@@ -53,7 +56,7 @@ int __drm_mode_object_add(struct drm_device *dev, struct drm_mode_object *obj,
 	}
 	mutex_unlock(&dev->mode_config.idr_mutex);
 
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 /**
diff --git a/drivers/gpu/drm/drm_syncobj.c b/drivers/gpu/drm/drm_syncobj.c
index 789ba0b..f7a0742 100644
--- a/drivers/gpu/drm/drm_syncobj.c
+++ b/drivers/gpu/drm/drm_syncobj.c
@@ -134,6 +134,7 @@ static int drm_syncobj_create(struct drm_file *file_private,
 			      u32 *handle)
 {
 	int ret;
+	unsigned long idr_index;
 	struct drm_syncobj *syncobj;
 
 	syncobj = kzalloc(sizeof(struct drm_syncobj), GFP_KERNEL);
@@ -144,17 +145,18 @@ static int drm_syncobj_create(struct drm_file *file_private,
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&file_private->syncobj_table_lock);
-	ret = idr_alloc(&file_private->syncobj_idr, syncobj, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc(&file_private->syncobj_idr, syncobj, &idr_index,
+			1, 0, GFP_NOWAIT);
 	spin_unlock(&file_private->syncobj_table_lock);
 
 	idr_preload_end();
 
-	if (ret < 0) {
+	if (ret) {
 		drm_syncobj_put(syncobj);
 		return ret;
 	}
 
-	*handle = ret;
+	*handle = idr_index;
 	return 0;
 }
 
@@ -253,6 +255,7 @@ static int drm_syncobj_fd_to_handle(struct drm_file *file_private,
 				    int fd, u32 *handle)
 {
 	struct drm_syncobj *syncobj = drm_syncobj_fdget(fd);
+	unsigned long idr_index;
 	int ret;
 
 	if (!syncobj)
@@ -263,15 +266,16 @@ static int drm_syncobj_fd_to_handle(struct drm_file *file_private,
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&file_private->syncobj_table_lock);
-	ret = idr_alloc(&file_private->syncobj_idr, syncobj, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc(&file_private->syncobj_idr, syncobj, &idr_index,
+			1, 0, GFP_NOWAIT);
 	spin_unlock(&file_private->syncobj_table_lock);
 	idr_preload_end();
 
-	if (ret < 0) {
+	if (ret) {
 		fput(syncobj->file);
 		return ret;
 	}
-	*handle = ret;
+	*handle = idr_index;
 	return 0;
 }
 
@@ -344,7 +348,7 @@ int drm_syncobj_export_sync_file(struct drm_file *file_private,
 }
 
 static int
-drm_syncobj_release_handle(int id, void *ptr, void *data)
+drm_syncobj_release_handle(unsigned long id, void *ptr, void *data)
 {
 	struct drm_syncobj *syncobj = ptr;
 
diff --git a/drivers/gpu/drm/exynos/exynos_drm_ipp.c b/drivers/gpu/drm/exynos/exynos_drm_ipp.c
index 3edda18..93c69af 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_ipp.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_ipp.c
@@ -117,12 +117,13 @@ int exynos_drm_ippdrv_unregister(struct exynos_drm_ippdrv *ippdrv)
 	return 0;
 }
 
-static int ipp_create_id(struct idr *id_idr, struct mutex *lock, void *obj)
+static int ipp_create_id(struct idr *id_idr, struct mutex *lock, void *obj,
+			 unsigned long *id)
 {
 	int ret;
 
 	mutex_lock(lock);
-	ret = idr_alloc(id_idr, obj, 1, 0, GFP_KERNEL);
+	ret = idr_alloc(id_idr, obj, id, 1, 0, GFP_KERNEL);
 	mutex_unlock(lock);
 
 	return ret;
@@ -326,6 +327,7 @@ int exynos_drm_ipp_set_property(struct drm_device *drm_dev, void *data,
 	struct drm_exynos_ipp_property *property = data;
 	struct exynos_drm_ippdrv *ippdrv;
 	struct drm_exynos_ipp_cmd_node *c_node;
+	unsigned long idr_index;
 	u32 prop_id;
 	int ret, i;
 
@@ -381,12 +383,13 @@ int exynos_drm_ipp_set_property(struct drm_device *drm_dev, void *data,
 	if (!c_node)
 		return -ENOMEM;
 
-	ret = ipp_create_id(&ctx->prop_idr, &ctx->prop_lock, c_node);
-	if (ret < 0) {
+	ret = ipp_create_id(&ctx->prop_idr, &ctx->prop_lock, c_node,
+			    &idr_index);
+	if (ret) {
 		DRM_ERROR("failed to create id.\n");
 		goto err_clear;
 	}
-	property->prop_id = ret;
+	property->prop_id = idr_index;
 
 	DRM_DEBUG_KMS("created prop_id[%d]cmd[%d]ippdrv[%pK]\n",
 		property->prop_id, property->cmd, ippdrv);
@@ -1588,21 +1591,23 @@ static int ipp_subdrv_probe(struct drm_device *drm_dev, struct device *dev)
 {
 	struct ipp_context *ctx = get_ipp_context(dev);
 	struct exynos_drm_ippdrv *ippdrv;
+	unsigned long idr_index;
 	int ret, count = 0;
 
 	/* get ipp driver entry */
 	list_for_each_entry(ippdrv, &exynos_drm_ippdrv_list, drv_list) {
 		ippdrv->drm_dev = drm_dev;
 
-		ret = ipp_create_id(&ctx->ipp_idr, &ctx->ipp_lock, ippdrv);
-		if (ret < 0) {
+		ret = ipp_create_id(&ctx->ipp_idr, &ctx->ipp_lock, ippdrv,
+				    &idr_index);
+		if (ret) {
 			DRM_ERROR("failed to create id.\n");
 			goto err;
 		}
-		ippdrv->prop_list.ipp_id = ret;
+		ippdrv->prop_list.ipp_id = idr_index;
 
-		DRM_DEBUG_KMS("count[%d]ippdrv[%pK]ipp_id[%d]\n",
-			count++, ippdrv, ret);
+		DRM_DEBUG_KMS("count[%d]ippdrv[%pK]ipp_id[%ld]\n",
+			      count++, ippdrv, idr_index);
 
 		/* store parent device for node */
 		ippdrv->parent_dev = dev;
diff --git a/drivers/gpu/drm/i915/gvt/display.c b/drivers/gpu/drm/i915/gvt/display.c
index 7cb0818..ce04352 100644
--- a/drivers/gpu/drm/i915/gvt/display.c
+++ b/drivers/gpu/drm/i915/gvt/display.c
@@ -394,7 +394,7 @@ static void emulate_vblank(struct intel_vgpu *vgpu)
 void intel_gvt_emulate_vblank(struct intel_gvt *gvt)
 {
 	struct intel_vgpu *vgpu;
-	int id;
+	unsigned long id;
 
 	if (WARN_ON(!mutex_is_locked(&gvt->lock)))
 		return;
diff --git a/drivers/gpu/drm/i915/gvt/kvmgt.c b/drivers/gpu/drm/i915/gvt/kvmgt.c
index fd0c85f..fb5c87f 100644
--- a/drivers/gpu/drm/i915/gvt/kvmgt.c
+++ b/drivers/gpu/drm/i915/gvt/kvmgt.c
@@ -1323,7 +1323,7 @@ static bool __kvmgt_vgpu_exist(struct intel_vgpu *vgpu, struct kvm *kvm)
 {
 	struct intel_vgpu *itr;
 	struct kvmgt_guest_info *info;
-	int id;
+	unsigned long id;
 	bool ret = false;
 
 	mutex_lock(&vgpu->gvt->lock);
diff --git a/drivers/gpu/drm/i915/gvt/vgpu.c b/drivers/gpu/drm/i915/gvt/vgpu.c
index 90c14e6..719b80c 100644
--- a/drivers/gpu/drm/i915/gvt/vgpu.c
+++ b/drivers/gpu/drm/i915/gvt/vgpu.c
@@ -324,6 +324,7 @@ static struct intel_vgpu *__intel_gvt_create_vgpu(struct intel_gvt *gvt,
 		struct intel_vgpu_creation_params *param)
 {
 	struct intel_vgpu *vgpu;
+	unsigned long idr_index;
 	int ret;
 
 	gvt_dbg_core("handle %llu low %llu MB high %llu MB fence %llu\n",
@@ -336,12 +337,12 @@ static struct intel_vgpu *__intel_gvt_create_vgpu(struct intel_gvt *gvt,
 
 	mutex_lock(&gvt->lock);
 
-	ret = idr_alloc(&gvt->vgpu_idr, vgpu, IDLE_VGPU_IDR + 1, GVT_MAX_VGPU,
-		GFP_KERNEL);
-	if (ret < 0)
+	ret = idr_alloc(&gvt->vgpu_idr, vgpu, &idr_index, IDLE_VGPU_IDR + 1,
+			GVT_MAX_VGPU, GFP_KERNEL);
+	if (ret)
 		goto out_free_vgpu;
 
-	vgpu->id = ret;
+	vgpu->id = idr_index;
 	vgpu->handle = param->handle;
 	vgpu->gvt = gvt;
 	vgpu->sched_ctl.weight = param->weight;
diff --git a/drivers/gpu/drm/i915/i915_debugfs.c b/drivers/gpu/drm/i915/i915_debugfs.c
index 00d8967..0818eac 100644
--- a/drivers/gpu/drm/i915/i915_debugfs.c
+++ b/drivers/gpu/drm/i915/i915_debugfs.c
@@ -286,7 +286,7 @@ struct file_stats {
 	u64 active, inactive;
 };
 
-static int per_file_stats(int id, void *ptr, void *data)
+static int per_file_stats(unsigned long id, void *ptr, void *data)
 {
 	struct drm_i915_gem_object *obj = ptr;
 	struct file_stats *stats = data;
@@ -359,7 +359,7 @@ static void print_batch_pool_stats(struct seq_file *m,
 	print_file_stats(m, "[k]batch pool", stats);
 }
 
-static int per_file_ctx_stats(int id, void *ptr, void *data)
+static int per_file_ctx_stats(unsigned long id, void *ptr, void *data)
 {
 	struct i915_gem_context *ctx = ptr;
 	int n;
@@ -2156,7 +2156,7 @@ static int i915_swizzle_info(struct seq_file *m, void *data)
 	return 0;
 }
 
-static int per_file_ctx(int id, void *ptr, void *data)
+static int per_file_ctx(unsigned long id, void *ptr, void *data)
 {
 	struct i915_gem_context *ctx = ptr;
 	struct seq_file *m = data;
diff --git a/drivers/gpu/drm/i915/i915_gem_context.c b/drivers/gpu/drm/i915/i915_gem_context.c
index 39ed58a..7d601b2 100644
--- a/drivers/gpu/drm/i915/i915_gem_context.c
+++ b/drivers/gpu/drm/i915/i915_gem_context.c
@@ -252,6 +252,7 @@ static u32 default_desc_template(const struct drm_i915_private *i915,
 		    struct drm_i915_file_private *file_priv)
 {
 	struct i915_gem_context *ctx;
+	unsigned long idr_index;
 	int ret;
 
 	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
@@ -283,12 +284,12 @@ static u32 default_desc_template(const struct drm_i915_private *i915,
 	/* Default context will never have a file_priv */
 	ret = DEFAULT_CONTEXT_HANDLE;
 	if (file_priv) {
-		ret = idr_alloc(&file_priv->context_idr, ctx,
+		ret = idr_alloc(&file_priv->context_idr, ctx, &idr_index,
 				DEFAULT_CONTEXT_HANDLE, 0, GFP_KERNEL);
-		if (ret < 0)
+		if (ret)
 			goto err_lut;
 	}
-	ctx->user_handle = ret;
+	ctx->user_handle = idr_index;
 
 	ctx->file_priv = file_priv;
 	if (file_priv) {
@@ -517,7 +518,7 @@ void i915_gem_context_fini(struct drm_i915_private *dev_priv)
 	ida_destroy(&dev_priv->context_hw_ida);
 }
 
-static int context_idr_cleanup(int id, void *p, void *data)
+static int context_idr_cleanup(unsigned long id, void *p, void *data)
 {
 	struct i915_gem_context *ctx = p;
 
diff --git a/drivers/gpu/drm/qxl/qxl_cmd.c b/drivers/gpu/drm/qxl/qxl_cmd.c
index 74fc936..81cff18 100644
--- a/drivers/gpu/drm/qxl/qxl_cmd.c
+++ b/drivers/gpu/drm/qxl/qxl_cmd.c
@@ -445,18 +445,18 @@ void qxl_io_monitors_config(struct qxl_device *qdev)
 int qxl_surface_id_alloc(struct qxl_device *qdev,
 		      struct qxl_bo *surf)
 {
-	uint32_t handle;
+	unsigned long handle;
 	int idr_ret;
 	int count = 0;
 again:
 	idr_preload(GFP_ATOMIC);
 	spin_lock(&qdev->surf_id_idr_lock);
-	idr_ret = idr_alloc(&qdev->surf_id_idr, NULL, 1, 0, GFP_NOWAIT);
+	idr_ret = idr_alloc(&qdev->surf_id_idr, NULL, &handle, 1, 0,
+			    GFP_NOWAIT);
 	spin_unlock(&qdev->surf_id_idr_lock);
 	idr_preload_end();
-	if (idr_ret < 0)
+	if (idr_ret)
 		return idr_ret;
-	handle = idr_ret;
 
 	if (handle >= qdev->rom->n_surfaces) {
 		count++;
diff --git a/drivers/gpu/drm/qxl/qxl_release.c b/drivers/gpu/drm/qxl/qxl_release.c
index e6ec845..c7b2047 100644
--- a/drivers/gpu/drm/qxl/qxl_release.c
+++ b/drivers/gpu/drm/qxl/qxl_release.c
@@ -128,8 +128,9 @@ static long qxl_fence_wait(struct dma_fence *fence, bool intr,
 		  struct qxl_release **ret)
 {
 	struct qxl_release *release;
-	int handle;
 	size_t size = sizeof(*release);
+	unsigned long handle;
+	int idr_ret;
 
 	release = kmalloc(size, GFP_KERNEL);
 	if (!release) {
@@ -144,19 +145,20 @@ static long qxl_fence_wait(struct dma_fence *fence, bool intr,
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&qdev->release_idr_lock);
-	handle = idr_alloc(&qdev->release_idr, release, 1, 0, GFP_NOWAIT);
+	idr_ret = idr_alloc(&qdev->release_idr, release, &handle, 1, 0,
+			    GFP_NOWAIT);
 	release->base.seqno = ++qdev->release_seqno;
 	spin_unlock(&qdev->release_idr_lock);
 	idr_preload_end();
-	if (handle < 0) {
+	if (idr_ret) {
 		kfree(release);
 		*ret = NULL;
-		return handle;
+		return idr_ret;
 	}
 	*ret = release;
-	QXL_INFO(qdev, "allocated release %d\n", handle);
+	QXL_INFO(qdev, "allocated release %lu\n", handle);
 	release->id = handle;
-	return handle;
+	return idr_ret;
 }
 
 static void
diff --git a/drivers/gpu/drm/sis/sis_mm.c b/drivers/gpu/drm/sis/sis_mm.c
index 1622db2..f69a49e 100644
--- a/drivers/gpu/drm/sis/sis_mm.c
+++ b/drivers/gpu/drm/sis/sis_mm.c
@@ -88,6 +88,7 @@ static int sis_drm_alloc(struct drm_device *dev, struct drm_file *file,
 	struct sis_memblock *item;
 	struct sis_file_private *file_priv = file->driver_priv;
 	unsigned long offset;
+	unsigned long idr_index;
 
 	mutex_lock(&dev->struct_mutex);
 
@@ -128,10 +129,11 @@ static int sis_drm_alloc(struct drm_device *dev, struct drm_file *file,
 	if (retval)
 		goto fail_alloc;
 
-	retval = idr_alloc(&dev_priv->object_idr, item, 1, 0, GFP_KERNEL);
-	if (retval < 0)
+	retval = idr_alloc(&dev_priv->object_idr, item, &idr_index, 1, 0,
+			   GFP_KERNEL);
+	if (retval)
 		goto fail_idr;
-	user_key = retval;
+	user_key = idr_index;
 
 	list_add(&item->owner_list, &file_priv->obj_list);
 	mutex_unlock(&dev->struct_mutex);
diff --git a/drivers/gpu/drm/tegra/drm.c b/drivers/gpu/drm/tegra/drm.c
index 518f4b6..290e994 100644
--- a/drivers/gpu/drm/tegra/drm.c
+++ b/drivers/gpu/drm/tegra/drm.c
@@ -644,20 +644,22 @@ static int tegra_client_open(struct tegra_drm_file *fpriv,
 			     struct tegra_drm_client *client,
 			     struct tegra_drm_context *context)
 {
+	unsigned long idr_index;
 	int err;
 
 	err = client->ops->open_channel(client, context);
 	if (err < 0)
 		return err;
 
-	err = idr_alloc(&fpriv->contexts, context, 1, 0, GFP_KERNEL);
-	if (err < 0) {
+	err = idr_alloc(&fpriv->contexts, context, &idr_index, 1, 0,
+			GFP_KERNEL);
+	if (err) {
 		client->ops->close_channel(context);
 		return err;
 	}
 
 	context->client = client;
-	context->id = err;
+	context->id = idr_index;
 
 	return 0;
 }
@@ -982,7 +984,7 @@ static int tegra_gem_get_flags(struct drm_device *drm, void *data,
 	.llseek = noop_llseek,
 };
 
-static int tegra_drm_context_cleanup(int id, void *p, void *data)
+static int tegra_drm_context_cleanup(unsigned long id, void *p, void *data)
 {
 	struct tegra_drm_context *context = p;
 
diff --git a/drivers/gpu/drm/tilcdc/tilcdc_slave_compat.c b/drivers/gpu/drm/tilcdc/tilcdc_slave_compat.c
index 623a914..66a4c1a 100644
--- a/drivers/gpu/drm/tilcdc/tilcdc_slave_compat.c
+++ b/drivers/gpu/drm/tilcdc/tilcdc_slave_compat.c
@@ -204,6 +204,7 @@ static void __init tilcdc_convert_slave_node(void)
 	/* For all memory needed for the overlay tree. This memory can
 	   be freed after the overlay has been applied. */
 	struct kfree_table kft;
+	unsigned long id;
 	int ret;
 
 	if (kfree_table_init(&kft))
@@ -247,7 +248,7 @@ static void __init tilcdc_convert_slave_node(void)
 
 	tilcdc_node_disable(slave);
 
-	ret = of_overlay_create(overlay);
+	ret = of_overlay_create(overlay, &id);
 	if (ret)
 		pr_err("%s: Creating overlay failed: %d\n", __func__, ret);
 	else
diff --git a/drivers/gpu/drm/vgem/vgem_fence.c b/drivers/gpu/drm/vgem/vgem_fence.c
index 3109c83..2558118 100644
--- a/drivers/gpu/drm/vgem/vgem_fence.c
+++ b/drivers/gpu/drm/vgem/vgem_fence.c
@@ -158,6 +158,7 @@ int vgem_fence_attach_ioctl(struct drm_device *dev,
 	struct reservation_object *resv;
 	struct drm_gem_object *obj;
 	struct dma_fence *fence;
+	unsigned long idr_index;
 	int ret;
 
 	if (arg->flags & ~VGEM_FENCE_WRITE)
@@ -200,12 +201,11 @@ int vgem_fence_attach_ioctl(struct drm_device *dev,
 	/* Record the fence in our idr for later signaling */
 	if (ret == 0) {
 		mutex_lock(&vfile->fence_mutex);
-		ret = idr_alloc(&vfile->fence_idr, fence, 1, 0, GFP_KERNEL);
+		ret = idr_alloc(&vfile->fence_idr, fence, &idr_index, 1, 0,
+				GFP_KERNEL);
 		mutex_unlock(&vfile->fence_mutex);
-		if (ret > 0) {
-			arg->out_fence = ret;
-			ret = 0;
-		}
+		if (ret == 0)
+			arg->out_fence = idr_index;
 	}
 err_fence:
 	if (ret) {
@@ -269,7 +269,7 @@ int vgem_fence_open(struct vgem_file *vfile)
 	return 0;
 }
 
-static int __vgem_fence_idr_fini(int id, void *p, void *data)
+static int __vgem_fence_idr_fini(unsigned long id, void *p, void *data)
 {
 	dma_fence_signal(p);
 	dma_fence_put(p);
diff --git a/drivers/gpu/drm/via/via_mm.c b/drivers/gpu/drm/via/via_mm.c
index 4217d66..4b848b3 100644
--- a/drivers/gpu/drm/via/via_mm.c
+++ b/drivers/gpu/drm/via/via_mm.c
@@ -116,6 +116,7 @@ int via_mem_alloc(struct drm_device *dev, void *data,
 	drm_via_private_t *dev_priv = (drm_via_private_t *) dev->dev_private;
 	struct via_file_private *file_priv = file->driver_priv;
 	unsigned long tmpSize;
+	unsigned long idr_index;
 
 	if (mem->type > VIA_MEM_AGP) {
 		DRM_ERROR("Unknown memory type allocation\n");
@@ -148,10 +149,11 @@ int via_mem_alloc(struct drm_device *dev, void *data,
 	if (retval)
 		goto fail_alloc;
 
-	retval = idr_alloc(&dev_priv->object_idr, item, 1, 0, GFP_KERNEL);
-	if (retval < 0)
+	retval = idr_alloc(&dev_priv->object_idr, item, &idr_index, 1, 0,
+			   GFP_KERNEL);
+	if (retval)
 		goto fail_idr;
-	user_key = retval;
+	user_key = idr_index;
 
 	list_add(&item->owner_list, &file_priv->obj_list);
 	mutex_unlock(&dev->struct_mutex);
diff --git a/drivers/gpu/drm/virtio/virtgpu_kms.c b/drivers/gpu/drm/virtio/virtgpu_kms.c
index 6400506..2a251c2 100644
--- a/drivers/gpu/drm/virtio/virtgpu_kms.c
+++ b/drivers/gpu/drm/virtio/virtgpu_kms.c
@@ -55,11 +55,12 @@ static void virtio_gpu_config_changed_work_func(struct work_struct *work)
 static void virtio_gpu_ctx_id_get(struct virtio_gpu_device *vgdev,
 				  uint32_t *resid)
 {
-	int handle;
+	int ret;
+	unsigned long handle;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&vgdev->ctx_id_idr_lock);
-	handle = idr_alloc(&vgdev->ctx_id_idr, NULL, 1, 0, 0);
+	ret = idr_alloc(&vgdev->ctx_id_idr, NULL, &handle, 1, 0, 0);
 	spin_unlock(&vgdev->ctx_id_idr_lock);
 	idr_preload_end();
 	*resid = handle;
diff --git a/drivers/gpu/drm/virtio/virtgpu_vq.c b/drivers/gpu/drm/virtio/virtgpu_vq.c
index 9eb96fb2..6d08d42 100644
--- a/drivers/gpu/drm/virtio/virtgpu_vq.c
+++ b/drivers/gpu/drm/virtio/virtgpu_vq.c
@@ -41,11 +41,12 @@
 void virtio_gpu_resource_id_get(struct virtio_gpu_device *vgdev,
 				uint32_t *resid)
 {
-	int handle;
+	int ret;
+	unsigned long handle;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&vgdev->resource_idr_lock);
-	handle = idr_alloc(&vgdev->resource_idr, NULL, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc(&vgdev->resource_idr, NULL, &handle, 1, 0, GFP_NOWAIT);
 	spin_unlock(&vgdev->resource_idr_lock);
 	idr_preload_end();
 	*resid = handle;
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c b/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
index a96f90f..5bade53 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
@@ -160,19 +160,20 @@ int vmw_resource_alloc_id(struct vmw_resource *res)
 	struct vmw_private *dev_priv = res->dev_priv;
 	int ret;
 	struct idr *idr = &dev_priv->res_idr[res->func->res_type];
+	unsigned long idr_index;
 
 	BUG_ON(res->id != -1);
 
 	idr_preload(GFP_KERNEL);
 	write_lock(&dev_priv->resource_lock);
 
-	ret = idr_alloc(idr, res, 1, 0, GFP_NOWAIT);
-	if (ret >= 0)
-		res->id = ret;
+	ret = idr_alloc(idr, res, &idr_index, 1, 0, GFP_NOWAIT);
+	if (ret == 0)
+		res->id = idr_index;
 
 	write_unlock(&dev_priv->resource_lock);
 	idr_preload_end();
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 /**
diff --git a/drivers/i2c/i2c-core-base.c b/drivers/i2c/i2c-core-base.c
index 12822a4..c867083 100644
--- a/drivers/i2c/i2c-core-base.c
+++ b/drivers/i2c/i2c-core-base.c
@@ -1306,13 +1306,15 @@ static int i2c_register_adapter(struct i2c_adapter *adap)
  */
 static int __i2c_add_numbered_adapter(struct i2c_adapter *adap)
 {
-	int id;
+	unsigned long idr_index;
+	int ret;
 
 	mutex_lock(&core_lock);
-	id = idr_alloc(&i2c_adapter_idr, adap, adap->nr, adap->nr + 1, GFP_KERNEL);
+	ret = idr_alloc(&i2c_adapter_idr, adap, &idr_index,
+			adap->nr, adap->nr + 1, GFP_KERNEL);
 	mutex_unlock(&core_lock);
-	if (WARN(id < 0, "couldn't get idr"))
-		return id == -ENOSPC ? -EBUSY : id;
+	if (WARN(ret, "couldn't get idr"))
+		return ret == -ENOSPC ? -EBUSY : ret;
 
 	return i2c_register_adapter(adap);
 }
@@ -1334,7 +1336,8 @@ static int __i2c_add_numbered_adapter(struct i2c_adapter *adap)
 int i2c_add_adapter(struct i2c_adapter *adapter)
 {
 	struct device *dev = &adapter->dev;
-	int id;
+	unsigned long id;
+	int ret;
 
 	if (dev->of_node) {
 		id = of_alias_get_id(dev->of_node, "i2c");
@@ -1345,11 +1348,11 @@ int i2c_add_adapter(struct i2c_adapter *adapter)
 	}
 
 	mutex_lock(&core_lock);
-	id = idr_alloc(&i2c_adapter_idr, adapter,
+	ret = idr_alloc(&i2c_adapter_idr, adapter, &id,
 		       __i2c_first_dynamic_bus_num, 0, GFP_KERNEL);
 	mutex_unlock(&core_lock);
-	if (WARN(id < 0, "couldn't get idr"))
-		return id;
+	if (WARN(ret, "couldn't get idr"))
+		return ret;
 
 	adapter->nr = id;
 
diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 2b4d613..4e7642c 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -493,18 +493,20 @@ static int cm_init_av_by_path(struct sa_path_rec *path, struct cm_av *av,
 static int cm_alloc_id(struct cm_id_private *cm_id_priv)
 {
 	unsigned long flags;
-	int id;
+	unsigned long id;
+	int ret;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock_irqsave(&cm.lock, flags);
 
-	id = idr_alloc_cyclic(&cm.local_id_table, cm_id_priv, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&cm.local_id_table, cm_id_priv, &id, 0, 0,
+			       GFP_NOWAIT);
 
 	spin_unlock_irqrestore(&cm.lock, flags);
 	idr_preload_end();
 
 	cm_id_priv->id.local_id = (__force __be32)id ^ cm.random_id_operand;
-	return id < 0 ? id : 0;
+	return ret;
 }
 
 static void cm_free_id(__be32 local_id)
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 0eb3932..258476d 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -216,11 +216,12 @@ struct class_port_info_context {
 };
 
 static int cma_ps_alloc(struct net *net, enum rdma_port_space ps,
-			struct rdma_bind_list *bind_list, int snum)
+			 struct rdma_bind_list *bind_list, int snum,
+			 unsigned long *port)
 {
 	struct idr *idr = cma_pernet_idr(net, ps);
 
-	return idr_alloc(idr, bind_list, snum, snum + 1, GFP_KERNEL);
+	return idr_alloc(idr, bind_list, port, snum, snum + 1, GFP_KERNEL);
 }
 
 static struct rdma_bind_list *cma_ps_find(struct net *net,
@@ -2977,6 +2978,7 @@ static int cma_alloc_port(enum rdma_port_space ps,
 			  struct rdma_id_private *id_priv, unsigned short snum)
 {
 	struct rdma_bind_list *bind_list;
+	unsigned long port;
 	int ret;
 
 	bind_list = kzalloc(sizeof *bind_list, GFP_KERNEL);
@@ -2984,12 +2986,12 @@ static int cma_alloc_port(enum rdma_port_space ps,
 		return -ENOMEM;
 
 	ret = cma_ps_alloc(id_priv->id.route.addr.dev_addr.net, ps, bind_list,
-			   snum);
-	if (ret < 0)
+			   snum, &port);
+	if (ret)
 		goto err;
 
 	bind_list->ps = ps;
-	bind_list->port = (unsigned short)ret;
+	bind_list->port = (unsigned short)port;
 	cma_bind_port(bind_list, id_priv);
 	return 0;
 err:
diff --git a/drivers/infiniband/core/rdma_core.c b/drivers/infiniband/core/rdma_core.c
index 41c31a2..63c06b9 100644
--- a/drivers/infiniband/core/rdma_core.c
+++ b/drivers/infiniband/core/rdma_core.c
@@ -102,6 +102,7 @@ static struct ib_uobject *alloc_uobj(struct ib_ucontext *context,
 
 static int idr_add_uobj(struct ib_uobject *uobj)
 {
+	unsigned long idr_index;
 	int ret;
 
 	idr_preload(GFP_KERNEL);
@@ -112,15 +113,15 @@ static int idr_add_uobj(struct ib_uobject *uobj)
 	 * object which isn't initialized yet. We'll replace it later on with
 	 * the real object once we commit.
 	 */
-	ret = idr_alloc(&uobj->context->ufile->idr, NULL, 0,
+	ret = idr_alloc(&uobj->context->ufile->idr, NULL, &idr_index, 0,
 			min_t(unsigned long, U32_MAX - 1, INT_MAX), GFP_NOWAIT);
-	if (ret >= 0)
-		uobj->id = ret;
+	if (ret == 0)
+		uobj->id = idr_index;
 
 	spin_unlock(&uobj->context->ufile->idr_lock);
 	idr_preload_end();
 
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 /*
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 70fa4ca..6b3d469 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -1400,19 +1400,20 @@ static int send_mad(struct ib_sa_query *query, int timeout_ms, gfp_t gfp_mask)
 {
 	bool preload = gfpflags_allow_blocking(gfp_mask);
 	unsigned long flags;
-	int ret, id;
+	unsigned long id;
+	int ret;
 
 	if (preload)
 		idr_preload(gfp_mask);
 	spin_lock_irqsave(&idr_lock, flags);
 
-	id = idr_alloc(&query_idr, query, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc(&query_idr, query, &id, 0, 0, GFP_NOWAIT);
 
 	spin_unlock_irqrestore(&idr_lock, flags);
 	if (preload)
 		idr_preload_end();
-	if (id < 0)
-		return id;
+	if (ret)
+		return ret;
 
 	query->mad_buf->timeout_ms  = timeout_ms;
 	query->mad_buf->context[0] = query;
@@ -1422,7 +1423,7 @@ static int send_mad(struct ib_sa_query *query, int timeout_ms, gfp_t gfp_mask)
 	    (!(query->flags & IB_SA_QUERY_OPA))) {
 		if (!ibnl_chk_listeners(RDMA_NL_GROUP_LS)) {
 			if (!ib_nl_make_request(query, gfp_mask))
-				return id;
+				return ret;
 		}
 		ib_sa_disable_local_svc(query);
 	}
@@ -1439,7 +1440,7 @@ static int send_mad(struct ib_sa_query *query, int timeout_ms, gfp_t gfp_mask)
 	 * send may already have completed and freed the query in
 	 * another context.
 	 */
-	return ret ? ret : id;
+	return ret;
 }
 
 void ib_sa_unpack_path(void *attribute, struct sa_path_rec *rec)
@@ -1672,7 +1673,7 @@ int ib_sa_path_rec_get(struct ib_sa_client *client,
 						query->conv_pr : rec;
 
 	ret = send_mad(&query->sa_query, timeout_ms, gfp_mask);
-	if (ret < 0)
+	if (ret)
 		goto err3;
 
 	return ret;
@@ -1796,7 +1797,7 @@ int ib_sa_service_rec_query(struct ib_sa_client *client,
 	*sa_query = &query->sa_query;
 
 	ret = send_mad(&query->sa_query, timeout_ms, gfp_mask);
-	if (ret < 0)
+	if (ret)
 		goto err2;
 
 	return ret;
@@ -1888,7 +1889,7 @@ int ib_sa_mcmember_rec_query(struct ib_sa_client *client,
 	*sa_query = &query->sa_query;
 
 	ret = send_mad(&query->sa_query, timeout_ms, gfp_mask);
-	if (ret < 0)
+	if (ret)
 		goto err2;
 
 	return ret;
@@ -1986,7 +1987,7 @@ int ib_sa_guid_info_rec_query(struct ib_sa_client *client,
 	*sa_query = &query->sa_query;
 
 	ret = send_mad(&query->sa_query, timeout_ms, gfp_mask);
-	if (ret < 0)
+	if (ret)
 		goto err2;
 
 	return ret;
@@ -2136,7 +2137,7 @@ static int ib_sa_classport_info_rec_query(struct ib_sa_port *port,
 	*sa_query = &query->sa_query;
 
 	ret = send_mad(&query->sa_query, timeout_ms, gfp_mask);
-	if (ret < 0)
+	if (ret)
 		goto err_free_mad;
 
 	return ret;
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index 112099c..5b2dd07 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -177,6 +177,8 @@ static void ib_ucm_cleanup_events(struct ib_ucm_context *ctx)
 static struct ib_ucm_context *ib_ucm_ctx_alloc(struct ib_ucm_file *file)
 {
 	struct ib_ucm_context *ctx;
+	unsigned long idr_index;
+	int ret;
 
 	ctx = kzalloc(sizeof *ctx, GFP_KERNEL);
 	if (!ctx)
@@ -188,11 +190,12 @@ static struct ib_ucm_context *ib_ucm_ctx_alloc(struct ib_ucm_file *file)
 	INIT_LIST_HEAD(&ctx->events);
 
 	mutex_lock(&ctx_id_mutex);
-	ctx->id = idr_alloc(&ctx_id_table, ctx, 0, 0, GFP_KERNEL);
+	ret = idr_alloc(&ctx_id_table, ctx, &idr_index, 0, 0, GFP_KERNEL);
 	mutex_unlock(&ctx_id_mutex);
-	if (ctx->id < 0)
+	if (ret)
 		goto error;
 
+	ctx->id = idr_index;
 	list_add_tail(&ctx->file_list, &file->ctxs);
 	return ctx;
 
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 276f0ef..c66b34fd 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -184,6 +184,8 @@ static void ucma_close_id(struct work_struct *work)
 static struct ucma_context *ucma_alloc_ctx(struct ucma_file *file)
 {
 	struct ucma_context *ctx;
+	unsigned long idr_index;
+	int ret;
 
 	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
 	if (!ctx)
@@ -196,11 +198,12 @@ static struct ucma_context *ucma_alloc_ctx(struct ucma_file *file)
 	ctx->file = file;
 
 	mutex_lock(&mut);
-	ctx->id = idr_alloc(&ctx_idr, ctx, 0, 0, GFP_KERNEL);
+	ret = idr_alloc(&ctx_idr, ctx, &idr_index, 0, 0, GFP_KERNEL);
 	mutex_unlock(&mut);
-	if (ctx->id < 0)
+	if (ret)
 		goto error;
 
+	ctx->id = idr_index;
 	list_add_tail(&ctx->list, &file->ctx_list);
 	return ctx;
 
@@ -212,17 +215,20 @@ static struct ucma_context *ucma_alloc_ctx(struct ucma_file *file)
 static struct ucma_multicast* ucma_alloc_multicast(struct ucma_context *ctx)
 {
 	struct ucma_multicast *mc;
+	unsigned long idr_index;
+	int ret;
 
 	mc = kzalloc(sizeof(*mc), GFP_KERNEL);
 	if (!mc)
 		return NULL;
 
 	mutex_lock(&mut);
-	mc->id = idr_alloc(&multicast_idr, mc, 0, 0, GFP_KERNEL);
+	ret = idr_alloc(&multicast_idr, mc, &idr_index, 0, 0, GFP_KERNEL);
 	mutex_unlock(&mut);
-	if (mc->id < 0)
+	if (ret)
 		goto error;
 
+	mc->id = idr_index;
 	mc->ctx = ctx;
 	list_add_tail(&mc->list, &ctx->mc_list);
 	return mc;
diff --git a/drivers/infiniband/hw/cxgb3/iwch.c b/drivers/infiniband/hw/cxgb3/iwch.c
index 47b2ce2..039e3b1 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.c
+++ b/drivers/infiniband/hw/cxgb3/iwch.c
@@ -63,7 +63,7 @@ struct cxgb3_client t3c_client = {
 static LIST_HEAD(dev_list);
 static DEFINE_MUTEX(dev_mutex);
 
-static int disable_qp_db(int id, void *p, void *data)
+static int disable_qp_db(unsigned long id, void *p, void *data)
 {
 	struct iwch_qp *qhp = p;
 
@@ -71,7 +71,7 @@ static int disable_qp_db(int id, void *p, void *data)
 	return 0;
 }
 
-static int enable_qp_db(int id, void *p, void *data)
+static int enable_qp_db(unsigned long id, void *p, void *data)
 {
 	struct iwch_qp *qhp = p;
 
diff --git a/drivers/infiniband/hw/cxgb3/iwch.h b/drivers/infiniband/hw/cxgb3/iwch.h
index 8378622..06efb1d 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.h
+++ b/drivers/infiniband/hw/cxgb3/iwch.h
@@ -157,13 +157,13 @@ static inline int insert_handle(struct iwch_dev *rhp, struct idr *idr,
 	idr_preload(GFP_KERNEL);
 	spin_lock_irq(&rhp->lock);
 
-	ret = idr_alloc(idr, handle, id, id + 1, GFP_NOWAIT);
+	ret = idr_alloc(idr, handle, NULL, id, id + 1, GFP_NOWAIT);
 
 	spin_unlock_irq(&rhp->lock);
 	idr_preload_end();
 
 	BUG_ON(ret == -ENOSPC);
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 static inline void remove_handle(struct iwch_dev *rhp, struct idr *idr, u32 id)
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index ae0b79a..d1bd4cd 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -87,7 +87,7 @@ struct c4iw_debugfs_data {
 	int pos;
 };
 
-static int count_idrs(int id, void *p, void *data)
+static int count_idrs(unsigned long id, void *p, void *data)
 {
 	int *countp = data;
 
@@ -260,7 +260,7 @@ static void set_ep_sin6_addrs(struct c4iw_ep *ep,
 	}
 }
 
-static int dump_qp(int id, void *p, void *data)
+static int dump_qp(unsigned long id, void *p, void *data)
 {
 	struct c4iw_qp *qp = p;
 	struct c4iw_debugfs_data *qpd = data;
@@ -382,7 +382,7 @@ static int qp_open(struct inode *inode, struct file *file)
 	.llseek  = default_llseek,
 };
 
-static int dump_stag(int id, void *p, void *data)
+static int dump_stag(unsigned long id, void *p, void *data)
 {
 	struct c4iw_debugfs_data *stagd = data;
 	int space;
@@ -562,7 +562,7 @@ static ssize_t stats_clear(struct file *file, const char __user *buf,
 	.write   = stats_clear,
 };
 
-static int dump_ep(int id, void *p, void *data)
+static int dump_ep(unsigned long id, void *p, void *data)
 {
 	struct c4iw_ep *ep = p;
 	struct c4iw_debugfs_data *epd = data;
@@ -621,7 +621,7 @@ static int dump_ep(int id, void *p, void *data)
 	return 0;
 }
 
-static int dump_listen_ep(int id, void *p, void *data)
+static int dump_listen_ep(unsigned long id, void *p, void *data)
 {
 	struct c4iw_listen_ep *ep = p;
 	struct c4iw_debugfs_data *epd = data;
@@ -1254,7 +1254,7 @@ static int c4iw_uld_state_change(void *handle, enum cxgb4_state new_state)
 	return 0;
 }
 
-static int disable_qp_db(int id, void *p, void *data)
+static int disable_qp_db(unsigned long id, void *p, void *data)
 {
 	struct c4iw_qp *qp = p;
 
@@ -1276,7 +1276,7 @@ static void stop_queues(struct uld_ctx *ctx)
 	spin_unlock_irqrestore(&ctx->dev->lock, flags);
 }
 
-static int enable_qp_db(int id, void *p, void *data)
+static int enable_qp_db(unsigned long id, void *p, void *data)
 {
 	struct c4iw_qp *qp = p;
 
@@ -1356,7 +1356,7 @@ struct qp_list {
 	struct c4iw_qp **qps;
 };
 
-static int add_and_ref_qp(int id, void *p, void *data)
+static int add_and_ref_qp(unsigned long id, void *p, void *data)
 {
 	struct qp_list *qp_listp = data;
 	struct c4iw_qp *qp = p;
@@ -1366,7 +1366,7 @@ static int add_and_ref_qp(int id, void *p, void *data)
 	return 0;
 }
 
-static int count_qps(int id, void *p, void *data)
+static int count_qps(unsigned long id, void *p, void *data)
 {
 	unsigned *countp = data;
 	(*countp)++;
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 819a306..2e65b95 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -303,7 +303,7 @@ static inline int _insert_handle(struct c4iw_dev *rhp, struct idr *idr,
 		spin_lock_irq(&rhp->lock);
 	}
 
-	ret = idr_alloc(idr, handle, id, id + 1, GFP_ATOMIC);
+	ret = idr_alloc(idr, handle, NULL, id, id + 1, GFP_ATOMIC);
 
 	if (lock) {
 		spin_unlock_irq(&rhp->lock);
@@ -311,7 +311,7 @@ static inline int _insert_handle(struct c4iw_dev *rhp, struct idr *idr,
 	}
 
 	BUG_ON(ret == -ENOSPC);
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 static inline int insert_handle(struct c4iw_dev *rhp, struct idr *idr,
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index 4a11d4d..30c97b2 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -1042,6 +1042,7 @@ struct hfi1_devdata *hfi1_alloc_devdata(struct pci_dev *pdev, size_t extra)
 	unsigned long flags;
 	struct hfi1_devdata *dd;
 	int ret, nports;
+	unsigned long idr_index;
 
 	/* extra is * number of ports */
 	nports = extra / sizeof(struct hfi1_pportdata);
@@ -1057,16 +1058,16 @@ struct hfi1_devdata *hfi1_alloc_devdata(struct pci_dev *pdev, size_t extra)
 	idr_preload(GFP_KERNEL);
 	spin_lock_irqsave(&hfi1_devs_lock, flags);
 
-	ret = idr_alloc(&hfi1_unit_table, dd, 0, 0, GFP_NOWAIT);
-	if (ret >= 0) {
-		dd->unit = ret;
+	ret = idr_alloc(&hfi1_unit_table, dd, &idr_index, 0, 0, GFP_NOWAIT);
+	if (ret == 0) {
+		dd->unit = idr_index;
 		list_add(&dd->list, &hfi1_dev_list);
 	}
 
 	spin_unlock_irqrestore(&hfi1_devs_lock, flags);
 	idr_preload_end();
 
-	if (ret < 0) {
+	if (ret) {
 		hfi1_early_err(&pdev->dev,
 			       "Could not allocate unit ID: error %d\n", -ret);
 		goto bail;
diff --git a/drivers/infiniband/hw/hfi1/vnic_main.c b/drivers/infiniband/hw/hfi1/vnic_main.c
index 339f0cd..3b4addc 100644
--- a/drivers/infiniband/hw/hfi1/vnic_main.c
+++ b/drivers/infiniband/hw/hfi1/vnic_main.c
@@ -593,7 +593,7 @@ void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet)
 		 */
 		if (unlikely(!vinfo)) {
 			struct hfi1_vnic_vport_info *vinfo_tmp;
-			int id_tmp = 0;
+			unsigned long id_tmp = 0;
 
 			vinfo_tmp =  idr_get_next(&dd->vnic.vesw_idr, &id_tmp);
 			if (vinfo_tmp) {
@@ -649,9 +649,9 @@ static int hfi1_vnic_up(struct hfi1_vnic_vport_info *vinfo)
 	if (!vinfo->vesw_id)
 		return -EINVAL;
 
-	rc = idr_alloc(&dd->vnic.vesw_idr, vinfo, vinfo->vesw_id,
+	rc = idr_alloc(&dd->vnic.vesw_idr, vinfo, NULL, vinfo->vesw_id,
 		       vinfo->vesw_id + 1, GFP_NOWAIT);
-	if (rc < 0)
+	if (rc)
 		return rc;
 
 	for (i = 0; i < vinfo->num_rx_q; i++) {
diff --git a/drivers/infiniband/hw/mlx4/cm.c b/drivers/infiniband/hw/mlx4/cm.c
index fedaf82..c99e5c8 100644
--- a/drivers/infiniband/hw/mlx4/cm.c
+++ b/drivers/infiniband/hw/mlx4/cm.c
@@ -245,6 +245,7 @@ static void sl_id_map_add(struct ib_device *ibdev, struct id_map_entry *new)
 	int ret;
 	struct id_map_entry *ent;
 	struct mlx4_ib_sriov *sriov = &to_mdev(ibdev)->sriov;
+	unsigned long idr_index;
 
 	ent = kmalloc(sizeof (struct id_map_entry), GFP_KERNEL);
 	if (!ent)
@@ -259,9 +260,10 @@ static void sl_id_map_add(struct ib_device *ibdev, struct id_map_entry *new)
 	idr_preload(GFP_KERNEL);
 	spin_lock(&to_mdev(ibdev)->sriov.id_map_lock);
 
-	ret = idr_alloc_cyclic(&sriov->pv_id_table, ent, 0, 0, GFP_NOWAIT);
-	if (ret >= 0) {
-		ent->pv_cm_id = (u32)ret;
+	ret = idr_alloc_cyclic(&sriov->pv_id_table, ent, &idr_index, 0, 0,
+			       GFP_NOWAIT);
+	if (ret == 0) {
+		ent->pv_cm_id = (u32)idr_index;
 		sl_id_map_add(ibdev, ent);
 		list_add_tail(&ent->list, &sriov->cm_list);
 	}
@@ -269,12 +271,13 @@ static void sl_id_map_add(struct ib_device *ibdev, struct id_map_entry *new)
 	spin_unlock(&sriov->id_map_lock);
 	idr_preload_end();
 
-	if (ret >= 0)
+	if (ret == 0)
 		return ent;
 
 	/*error flow*/
 	kfree(ent);
-	mlx4_ib_warn(ibdev, "No more space in the idr (err:0x%x)\n", ret);
+	mlx4_ib_warn(ibdev, "No more space in the idr (err:0x%lx)\n",
+		     idr_index);
 	return ERR_PTR(-ENOMEM);
 }
 
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_main.c b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
index 57c9a2a..5224c99 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_main.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_main.c
@@ -302,6 +302,8 @@ static struct ocrdma_dev *ocrdma_add(struct be_dev_info *dev_info)
 	int status = 0, i;
 	u8 lstate = 0;
 	struct ocrdma_dev *dev;
+	unsigned long idr_index;
+	int ret;
 
 	dev = (struct ocrdma_dev *)ib_alloc_device(sizeof(struct ocrdma_dev));
 	if (!dev) {
@@ -313,9 +315,10 @@ static struct ocrdma_dev *ocrdma_add(struct be_dev_info *dev_info)
 		goto idr_err;
 
 	memcpy(&dev->nic_info, dev_info, sizeof(*dev_info));
-	dev->id = idr_alloc(&ocrdma_dev_id, NULL, 0, 0, GFP_KERNEL);
-	if (dev->id < 0)
+	ret = idr_alloc(&ocrdma_dev_id, NULL, &idr_index, 0, 0, GFP_KERNEL);
+	if (ret)
 		goto idr_err;
+	dev->id = idr_index;
 
 	status = ocrdma_init_hw(dev);
 	if (status)
diff --git a/drivers/infiniband/hw/qib/qib_init.c b/drivers/infiniband/hw/qib/qib_init.c
index 6c16ba1..3bbe99f 100644
--- a/drivers/infiniband/hw/qib/qib_init.c
+++ b/drivers/infiniband/hw/qib/qib_init.c
@@ -1099,6 +1099,7 @@ struct qib_devdata *qib_alloc_devdata(struct pci_dev *pdev, size_t extra)
 	unsigned long flags;
 	struct qib_devdata *dd;
 	int ret, nports;
+	unsigned long idr_index;
 
 	/* extra is * number of ports */
 	nports = extra / sizeof(struct qib_pportdata);
@@ -1112,16 +1113,16 @@ struct qib_devdata *qib_alloc_devdata(struct pci_dev *pdev, size_t extra)
 	idr_preload(GFP_KERNEL);
 	spin_lock_irqsave(&qib_devs_lock, flags);
 
-	ret = idr_alloc(&qib_unit_table, dd, 0, 0, GFP_NOWAIT);
-	if (ret >= 0) {
-		dd->unit = ret;
+	ret = idr_alloc(&qib_unit_table, dd, &idr_index, 0, 0, GFP_NOWAIT);
+	if (ret == 0) {
+		dd->unit = idr_index;
 		list_add(&dd->list, &qib_dev_list);
 	}
 
 	spin_unlock_irqrestore(&qib_devs_lock, flags);
 	idr_preload_end();
 
-	if (ret < 0) {
+	if (ret) {
 		qib_early_err(&pdev->dev,
 			      "Could not allocate unit ID: error %d\n", -ret);
 		goto bail;
diff --git a/drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c b/drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c
index cf768dd..b220e91 100644
--- a/drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c
+++ b/drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c
@@ -204,9 +204,9 @@ static struct opa_vnic_adapter *vema_add_vport(struct opa_vnic_vema_port *port,
 		int rc;
 
 		adapter->cport = cport;
-		rc = idr_alloc(&port->vport_idr, adapter, vport_num,
+		rc = idr_alloc(&port->vport_idr, adapter, NULL, vport_num,
 			       vport_num + 1, GFP_NOWAIT);
-		if (rc < 0) {
+		if (rc) {
 			opa_vnic_rem_netdev(adapter);
 			adapter = ERR_PTR(rc);
 		}
@@ -850,7 +850,7 @@ void opa_vnic_vema_send_trap(struct opa_vnic_adapter *adapter,
 	v_err("Aborting trap\n");
 }
 
-static int vema_rem_vport(int id, void *p, void *data)
+static int vema_rem_vport(unsigned long id, void *p, void *data)
 {
 	struct opa_vnic_adapter *adapter = p;
 
@@ -858,7 +858,7 @@ static int vema_rem_vport(int id, void *p, void *data)
 	return 0;
 }
 
-static int vema_enable_vport(int id, void *p, void *data)
+static int vema_enable_vport(unsigned long id, void *p, void *data)
 {
 	struct opa_vnic_adapter *adapter = p;
 
@@ -866,7 +866,7 @@ static int vema_enable_vport(int id, void *p, void *data)
 	return 0;
 }
 
-static int vema_disable_vport(int id, void *p, void *data)
+static int vema_disable_vport(unsigned long id, void *p, void *data)
 {
 	struct opa_vnic_adapter *adapter = p;
 
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index f167c0d..bf30a25 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -299,6 +299,7 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
 	struct mm_struct *mm = NULL;
 	int pasid_max;
 	int ret;
+	unsigned long idr_index;
 
 	if (WARN_ON(!iommu))
 		return -EINVAL;
@@ -320,7 +321,7 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
 
 	mutex_lock(&pasid_mutex);
 	if (pasid && !(flags & SVM_FLAG_PRIVATE_PASID)) {
-		int i;
+		unsigned long i;
 
 		idr_for_each_entry(&iommu->pasid_idr, svm, i) {
 			if (svm->mm != mm ||
@@ -382,14 +383,14 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
 			pasid_max = iommu->pasid_max;
 
 		/* Do not use PASID 0 in caching mode (virtualised IOMMU) */
-		ret = idr_alloc(&iommu->pasid_idr, svm,
+		ret = idr_alloc(&iommu->pasid_idr, svm, &idr_index,
 				!!cap_caching_mode(iommu->cap),
 				pasid_max - 1, GFP_KERNEL);
-		if (ret < 0) {
+		if (ret) {
 			kfree(svm);
 			goto out;
 		}
-		svm->pasid = ret;
+		svm->pasid = idr_index;
 		svm->notifier.ops = &intel_mmuops;
 		svm->mm = mm;
 		svm->flags = flags;
diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index 2edbcc2..974884c 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -1607,11 +1607,12 @@ static int specific_minor(int minor)
 	idr_preload(GFP_KERNEL);
 	spin_lock(&_minor_lock);
 
-	r = idr_alloc(&_minor_idr, MINOR_ALLOCED, minor, minor + 1, GFP_NOWAIT);
+	r = idr_alloc(&_minor_idr, MINOR_ALLOCED, NULL, minor, minor + 1,
+		      GFP_NOWAIT);
 
 	spin_unlock(&_minor_lock);
 	idr_preload_end();
-	if (r < 0)
+	if (r)
 		return r == -ENOSPC ? -EBUSY : r;
 	return 0;
 }
@@ -1619,17 +1620,19 @@ static int specific_minor(int minor)
 static int next_free_minor(int *minor)
 {
 	int r;
+	unsigned long idr_index;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&_minor_lock);
 
-	r = idr_alloc(&_minor_idr, MINOR_ALLOCED, 0, 1 << MINORBITS, GFP_NOWAIT);
+	r = idr_alloc(&_minor_idr, MINOR_ALLOCED, &idr_index,
+		      0, 1 << MINORBITS, GFP_NOWAIT);
 
 	spin_unlock(&_minor_lock);
 	idr_preload_end();
-	if (r < 0)
+	if (r)
 		return r;
-	*minor = r;
+	*minor = idr_index;
 	return 0;
 }
 
diff --git a/drivers/memstick/core/memstick.c b/drivers/memstick/core/memstick.c
index 76382c8..266ef03 100644
--- a/drivers/memstick/core/memstick.c
+++ b/drivers/memstick/core/memstick.c
@@ -511,17 +511,19 @@ struct memstick_host *memstick_alloc_host(unsigned int extra,
 int memstick_add_host(struct memstick_host *host)
 {
 	int rc;
+	unsigned long idr_index;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&memstick_host_lock);
 
-	rc = idr_alloc(&memstick_host_idr, host, 0, 0, GFP_NOWAIT);
-	if (rc >= 0)
-		host->id = rc;
+	rc = idr_alloc(&memstick_host_idr, host, &idr_index, 0, 0,
+		       GFP_NOWAIT);
+	if (rc == 0)
+		host->id = idr_index;
 
 	spin_unlock(&memstick_host_lock);
 	idr_preload_end();
-	if (rc < 0)
+	if (rc)
 		return rc;
 
 	dev_set_name(&host->dev, "memstick%u", host->id);
diff --git a/drivers/memstick/core/ms_block.c b/drivers/memstick/core/ms_block.c
index 22de7f5..b1f33f2 100644
--- a/drivers/memstick/core/ms_block.c
+++ b/drivers/memstick/core/ms_block.c
@@ -2099,16 +2099,19 @@ static int msb_init_disk(struct memstick_dev *card)
 	int rc;
 	u64 limit = BLK_BOUNCE_HIGH;
 	unsigned long capacity;
+	unsigned long idr_index;
 
 	if (host->dev.dma_mask && *(host->dev.dma_mask))
 		limit = *(host->dev.dma_mask);
 
 	mutex_lock(&msb_disk_lock);
-	msb->disk_id = idr_alloc(&msb_disk_idr, card, 0, 256, GFP_KERNEL);
+	rc = idr_alloc(&msb_disk_idr, card, &idr_index, 0, 256, GFP_KERNEL);
 	mutex_unlock(&msb_disk_lock);
 
-	if (msb->disk_id  < 0)
-		return msb->disk_id;
+	if (rc)
+		return rc;
+
+	msb->disk_id = idr_index;
 
 	msb->disk = alloc_disk(0);
 	if (!msb->disk) {
diff --git a/drivers/memstick/core/mspro_block.c b/drivers/memstick/core/mspro_block.c
index 8897962..51204ae 100644
--- a/drivers/memstick/core/mspro_block.c
+++ b/drivers/memstick/core/mspro_block.c
@@ -1177,6 +1177,8 @@ static int mspro_block_init_disk(struct memstick_dev *card)
 	int rc, disk_id;
 	u64 limit = BLK_BOUNCE_HIGH;
 	unsigned long capacity;
+	unsigned long idr_index;
+	int ret;
 
 	if (host->dev.dma_mask && *(host->dev.dma_mask))
 		limit = *(host->dev.dma_mask);
@@ -1200,10 +1202,14 @@ static int mspro_block_init_disk(struct memstick_dev *card)
 	msb->page_size = be16_to_cpu(sys_info->unit_size);
 
 	mutex_lock(&mspro_block_disk_lock);
-	disk_id = idr_alloc(&mspro_block_disk_idr, card, 0, 256, GFP_KERNEL);
+	ret = idr_alloc(&mspro_block_disk_idr, card, &idr_index, 0, 256,
+			GFP_KERNEL);
 	mutex_unlock(&mspro_block_disk_lock);
-	if (disk_id < 0)
-		return disk_id;
+
+	if (ret)
+		return ret;
+
+	disk_id = idr_index;
 
 	msb->disk = alloc_disk(1 << MSPRO_BLOCK_PART_SHIFT);
 	if (!msb->disk) {
diff --git a/drivers/mfd/rtsx_pcr.c b/drivers/mfd/rtsx_pcr.c
index a0ac89d..ef44cf0 100644
--- a/drivers/mfd/rtsx_pcr.c
+++ b/drivers/mfd/rtsx_pcr.c
@@ -1172,6 +1172,7 @@ static int rtsx_pci_probe(struct pci_dev *pcidev,
 	struct pcr_handle *handle;
 	u32 base, len;
 	int ret, i, bar = 0;
+	unsigned long idr_index;
 
 	dev_dbg(&(pcidev->dev),
 		": Realtek PCI-E Card Reader found at %s [%04x:%04x] (rev %x)\n",
@@ -1205,12 +1206,12 @@ static int rtsx_pci_probe(struct pci_dev *pcidev,
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&rtsx_pci_lock);
-	ret = idr_alloc(&rtsx_pci_idr, pcr, 0, 0, GFP_NOWAIT);
-	if (ret >= 0)
-		pcr->id = ret;
+	ret = idr_alloc(&rtsx_pci_idr, pcr, &idr_index, 0, 0, GFP_NOWAIT);
+	if (ret == 0)
+		pcr->id = idr_index;
 	spin_unlock(&rtsx_pci_lock);
 	idr_preload_end();
-	if (ret < 0)
+	if (ret)
 		goto free_handle;
 
 	pcr->pci = pcidev;
diff --git a/drivers/misc/c2port/core.c b/drivers/misc/c2port/core.c
index 1922cb8..f21cd35 100644
--- a/drivers/misc/c2port/core.c
+++ b/drivers/misc/c2port/core.c
@@ -896,6 +896,7 @@ struct c2port_device *c2port_device_register(char *name,
 					struct c2port_ops *ops, void *devdata)
 {
 	struct c2port_device *c2dev;
+	unsigned long idr_index;
 	int ret;
 
 	if (unlikely(!ops) || unlikely(!ops->access) || \
@@ -910,13 +911,13 @@ struct c2port_device *c2port_device_register(char *name,
 
 	idr_preload(GFP_KERNEL);
 	spin_lock_irq(&c2port_idr_lock);
-	ret = idr_alloc(&c2port_idr, c2dev, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc(&c2port_idr, c2dev, &idr_index, 0, 0, GFP_NOWAIT);
 	spin_unlock_irq(&c2port_idr_lock);
 	idr_preload_end();
 
-	if (ret < 0)
+	if (ret)
 		goto error_idr_alloc;
-	c2dev->id = ret;
+	c2dev->id = idr_index;
 
 	bin_attr_flash_data.size = ops->blocks_num * ops->block_size;
 
diff --git a/drivers/misc/cxl/context.c b/drivers/misc/cxl/context.c
index 8c32040..cf32e3b 100644
--- a/drivers/misc/cxl/context.c
+++ b/drivers/misc/cxl/context.c
@@ -38,6 +38,7 @@ struct cxl_context *cxl_context_alloc(void)
 int cxl_context_init(struct cxl_context *ctx, struct cxl_afu *afu, bool master)
 {
 	int i;
+	unsigned long idr_index;
 
 	ctx->afu = afu;
 	ctx->master = master;
@@ -93,14 +94,15 @@ int cxl_context_init(struct cxl_context *ctx, struct cxl_afu *afu, bool master)
 	 */
 	mutex_lock(&afu->contexts_lock);
 	idr_preload(GFP_KERNEL);
-	i = idr_alloc(&ctx->afu->contexts_idr, ctx, ctx->afu->adapter->min_pe,
+	i = idr_alloc(&ctx->afu->contexts_idr, ctx, &idr_index,
+		      ctx->afu->adapter->min_pe,
 		      ctx->afu->num_procs, GFP_NOWAIT);
 	idr_preload_end();
 	mutex_unlock(&afu->contexts_lock);
-	if (i < 0)
+	if (i)
 		return i;
 
-	ctx->pe = i;
+	ctx->pe = idr_index;
 	if (cpu_has_feature(CPU_FTR_HVMODE)) {
 		ctx->elem = &ctx->afu->native->spa[i];
 		ctx->external_pe = ctx->pe;
diff --git a/drivers/misc/cxl/main.c b/drivers/misc/cxl/main.c
index c1ba0d4..cb2f9a9 100644
--- a/drivers/misc/cxl/main.c
+++ b/drivers/misc/cxl/main.c
@@ -80,7 +80,8 @@ static inline void cxl_slbia_core(struct mm_struct *mm)
 	struct cxl *adapter;
 	struct cxl_afu *afu;
 	struct cxl_context *ctx;
-	int card, slice, id;
+	int slice;
+	unsigned long card, id;
 
 	pr_devel("%s called\n", __func__);
 
@@ -202,17 +203,19 @@ struct cxl *get_cxl_adapter(int num)
 
 static int cxl_alloc_adapter_nr(struct cxl *adapter)
 {
-	int i;
+	int ret;
+	unsigned long idr_index;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&adapter_idr_lock);
-	i = idr_alloc(&cxl_adapter_idr, adapter, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc(&cxl_adapter_idr, adapter, &idr_index, 0, 0,
+		      GFP_NOWAIT);
 	spin_unlock(&adapter_idr_lock);
 	idr_preload_end();
-	if (i < 0)
-		return i;
+	if (ret)
+		return ret;
 
-	adapter->adapter_num = i;
+	adapter->adapter_num = idr_index;
 
 	return 0;
 }
diff --git a/drivers/misc/mei/main.c b/drivers/misc/mei/main.c
index e825f01..7c8c39f 100644
--- a/drivers/misc/mei/main.c
+++ b/drivers/misc/mei/main.c
@@ -792,11 +792,13 @@ static ssize_t hbm_ver_drv_show(struct device *device,
 static int mei_minor_get(struct mei_device *dev)
 {
 	int ret;
+	unsigned long idr_index;
 
 	mutex_lock(&mei_minor_lock);
-	ret = idr_alloc(&mei_idr, dev, 0, MEI_MAX_DEVS, GFP_KERNEL);
-	if (ret >= 0)
-		dev->minor = ret;
+	ret = idr_alloc(&mei_idr, dev, &idr_index, 0, MEI_MAX_DEVS,
+			GFP_KERNEL);
+	if (ret == 0)
+		dev->minor = idr_index;
 	else if (ret == -ENOSPC)
 		dev_err(dev->dev, "too many mei devices\n");
 
diff --git a/drivers/misc/mic/scif/scif_api.c b/drivers/misc/mic/scif/scif_api.c
index ddc9e4b..d07cb6c 100644
--- a/drivers/misc/mic/scif/scif_api.c
+++ b/drivers/misc/mic/scif/scif_api.c
@@ -336,6 +336,7 @@ int __scif_flush(scif_epd_t epd)
 int scif_bind(scif_epd_t epd, u16 pn)
 {
 	struct scif_endpt *ep = (struct scif_endpt *)epd;
+	unsigned long port;
 	int ret = 0;
 	int tmp;
 
@@ -364,14 +365,14 @@ int scif_bind(scif_epd_t epd, u16 pn)
 	}
 
 	if (pn) {
-		tmp = scif_rsrv_port(pn);
-		if (tmp != pn) {
+		tmp = scif_rsrv_port(pn, &port);
+		if (port != pn) {
 			ret = -EINVAL;
 			goto scif_bind_exit;
 		}
 	} else {
-		pn = scif_get_new_port();
-		if (!pn) {
+		pn = scif_get_new_port(&port);
+		if (pn < 0) {
 			ret = -ENOSPC;
 			goto scif_bind_exit;
 		}
@@ -379,7 +380,7 @@ int scif_bind(scif_epd_t epd, u16 pn)
 
 	ep->state = SCIFEP_BOUND;
 	ep->port.node = scif_info.nodeid;
-	ep->port.port = pn;
+	ep->port.port = port;
 	ep->conn_async_state = ASYNC_CONN_IDLE;
 	ret = pn;
 	dev_dbg(scif_info.mdev.this_device,
diff --git a/drivers/misc/mic/scif/scif_ports.c b/drivers/misc/mic/scif/scif_ports.c
index 594e18d..8a1938f 100644
--- a/drivers/misc/mic/scif/scif_ports.c
+++ b/drivers/misc/mic/scif/scif_ports.c
@@ -41,19 +41,19 @@ struct scif_port {
  * @return : Allocated SCIF port #, or -ENOSPC if port unavailable.
  *		On memory allocation failure, returns -ENOMEM.
  */
-static int __scif_get_port(int start, int end)
+static int __scif_get_port(unsigned long index, int start, int end)
 {
-	int id;
+	int ret;
 	struct scif_port *port = kzalloc(sizeof(*port), GFP_ATOMIC);
 
 	if (!port)
 		return -ENOMEM;
 	spin_lock(&scif_info.port_lock);
-	id = idr_alloc(&scif_ports, port, start, end, GFP_ATOMIC);
-	if (id >= 0)
+	ret = idr_alloc(&scif_ports, port, &index, start, end, GFP_ATOMIC);
+	if (ret == 0)
 		port->ref_cnt++;
 	spin_unlock(&scif_info.port_lock);
-	return id;
+	return ret;
 }
 
 /**
@@ -63,9 +63,9 @@ static int __scif_get_port(int start, int end)
  * @return : Allocated SCIF port #, or -ENOSPC if port unavailable.
  *		On memory allocation failure, returns -ENOMEM.
  */
-int scif_rsrv_port(u16 port)
+int scif_rsrv_port(u16 port, unsigned long *index)
 {
-	return __scif_get_port(port, port + 1);
+	return __scif_get_port(index, port, port + 1);
 }
 
 /**
@@ -75,9 +75,9 @@ int scif_rsrv_port(u16 port)
  * @return : Allocated SCIF port #, or -ENOSPC if no ports available.
  *		On memory allocation failure, returns -ENOMEM.
  */
-int scif_get_new_port(void)
+int scif_get_new_port(unsigned long *index)
 {
-	return __scif_get_port(SCIF_PORT_RSVD + 1, SCIF_PORT_COUNT);
+	return __scif_get_port(index, SCIF_PORT_RSVD + 1, SCIF_PORT_COUNT);
 }
 
 /**
diff --git a/drivers/misc/tifm_core.c b/drivers/misc/tifm_core.c
index a511b2a..d4b0777 100644
--- a/drivers/misc/tifm_core.c
+++ b/drivers/misc/tifm_core.c
@@ -197,15 +197,16 @@ struct tifm_adapter *tifm_alloc_adapter(unsigned int num_sockets,
 int tifm_add_adapter(struct tifm_adapter *fm)
 {
 	int rc;
+	unsigned long idr_index;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&tifm_adapter_lock);
-	rc = idr_alloc(&tifm_adapter_idr, fm, 0, 0, GFP_NOWAIT);
-	if (rc >= 0)
-		fm->id = rc;
+	rc = idr_alloc(&tifm_adapter_idr, fm, &idr_index, 0, 0, GFP_NOWAIT);
+	if (rc == 0)
+		fm->id = idr_index;
 	spin_unlock(&tifm_adapter_lock);
 	idr_preload_end();
-	if (rc < 0)
+	if (rc)
 		return rc;
 
 	dev_set_name(&fm->dev, "tifm%u", fm->id);
diff --git a/drivers/mtd/mtdcore.c b/drivers/mtd/mtdcore.c
index 956382c..da2d6a4 100644
--- a/drivers/mtd/mtdcore.c
+++ b/drivers/mtd/mtdcore.c
@@ -85,7 +85,7 @@ static int mtd_cls_resume(struct device *dev)
 DEFINE_MUTEX(mtd_table_mutex);
 EXPORT_SYMBOL_GPL(mtd_table_mutex);
 
-struct mtd_info *__mtd_next_device(int i)
+struct mtd_info *__mtd_next_device(unsigned long i)
 {
 	return idr_get_next(&mtd_idr, &i);
 }
@@ -489,6 +489,7 @@ int mtd_pairing_groups(struct mtd_info *mtd)
 int add_mtd_device(struct mtd_info *mtd)
 {
 	struct mtd_notifier *not;
+	unsigned long idr_index;
 	int i, error;
 
 	/*
@@ -502,13 +503,13 @@ int add_mtd_device(struct mtd_info *mtd)
 	BUG_ON(mtd->writesize == 0);
 	mutex_lock(&mtd_table_mutex);
 
-	i = idr_alloc(&mtd_idr, mtd, 0, 0, GFP_KERNEL);
-	if (i < 0) {
+	i = idr_alloc(&mtd_idr, mtd, &idr_index, 0, 0, GFP_KERNEL);
+	if (i) {
 		error = i;
 		goto fail_locked;
 	}
 
-	mtd->index = i;
+	mtd->index = idr_index;
 	mtd->usecount = 0;
 
 	/* default value if not set by driver */
diff --git a/drivers/mtd/mtdcore.h b/drivers/mtd/mtdcore.h
index 55fdb8e..28c5674 100644
--- a/drivers/mtd/mtdcore.h
+++ b/drivers/mtd/mtdcore.h
@@ -5,7 +5,7 @@
 
 extern struct mutex mtd_table_mutex;
 
-struct mtd_info *__mtd_next_device(int i);
+struct mtd_info *__mtd_next_device(unsigned long i);
 int add_mtd_device(struct mtd_info *mtd);
 int del_mtd_device(struct mtd_info *mtd);
 int add_mtd_partitions(struct mtd_info *, const struct mtd_partition *, int);
diff --git a/drivers/mtd/ubi/block.c b/drivers/mtd/ubi/block.c
index c3963f8..96be456 100644
--- a/drivers/mtd/ubi/block.c
+++ b/drivers/mtd/ubi/block.c
@@ -358,6 +358,7 @@ int ubiblock_create(struct ubi_volume_info *vi)
 	struct ubiblock *dev;
 	struct gendisk *gd;
 	u64 disk_capacity = vi->used_bytes >> 9;
+	unsigned long idr_index;
 	int ret;
 
 	if ((sector_t)disk_capacity != disk_capacity)
@@ -390,13 +391,15 @@ int ubiblock_create(struct ubi_volume_info *vi)
 
 	gd->fops = &ubiblock_ops;
 	gd->major = ubiblock_major;
-	gd->first_minor = idr_alloc(&ubiblock_minor_idr, dev, 0, 0, GFP_KERNEL);
-	if (gd->first_minor < 0) {
+	ret = idr_alloc(&ubiblock_minor_idr, dev, &idr_index,
+			0, 0, GFP_KERNEL);
+	if (ret) {
 		dev_err(disk_to_dev(gd),
 			"block: dynamic minor allocation failed");
 		ret = -ENODEV;
 		goto out_put_disk;
 	}
+	gd->first_minor = idr_index;
 	gd->private_data = dev;
 	sprintf(gd->disk_name, "ubiblock%d_%d", dev->ubi_num, dev->vol_id);
 	set_capacity(gd, disk_capacity);
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index a404552..b982238 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -286,7 +286,7 @@ static void ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb,
 static int ppp_connect_channel(struct channel *pch, int unit);
 static int ppp_disconnect_channel(struct channel *pch);
 static void ppp_destroy_channel(struct channel *pch);
-static int unit_get(struct idr *p, void *ptr);
+static int unit_get(struct idr *p, void *ptr, unsigned long *index);
 static int unit_set(struct idr *p, void *ptr, int n);
 static void unit_put(struct idr *p, int n);
 static void *unit_find(struct idr *p, int n);
@@ -943,7 +943,7 @@ static __net_exit void ppp_exit_net(struct net *net)
 	struct net_device *aux;
 	struct ppp *ppp;
 	LIST_HEAD(list);
-	int id;
+	unsigned long id;
 
 	rtnl_lock();
 	for_each_netdev_safe(net, dev, aux) {
@@ -972,13 +972,14 @@ static __net_exit void ppp_exit_net(struct net *net)
 static int ppp_unit_register(struct ppp *ppp, int unit, bool ifname_is_set)
 {
 	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
+	unsigned long idr_index;
 	int ret;
 
 	mutex_lock(&pn->all_ppp_mutex);
 
 	if (unit < 0) {
-		ret = unit_get(&pn->units_idr, ppp);
-		if (ret < 0)
+		ret = unit_get(&pn->units_idr, ppp, &idr_index);
+		if (ret)
 			goto err;
 	} else {
 		/* Caller asked for a specific unit number. Fail with -EEXIST
@@ -991,13 +992,13 @@ static int ppp_unit_register(struct ppp *ppp, int unit, bool ifname_is_set)
 			goto err;
 		}
 		ret = unit_set(&pn->units_idr, ppp, unit);
-		if (ret < 0) {
+		if (ret) {
 			/* Rewrite error for backward compatibility */
 			ret = -EEXIST;
 			goto err;
 		}
 	}
-	ppp->file.index = ret;
+	ppp->file.index = idr_index;
 
 	if (!ifname_is_set)
 		snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
@@ -3222,18 +3223,18 @@ static void __exit ppp_cleanup(void)
 /* associate pointer with specified number */
 static int unit_set(struct idr *p, void *ptr, int n)
 {
-	int unit;
+	int ret;
 
-	unit = idr_alloc(p, ptr, n, n + 1, GFP_KERNEL);
-	if (unit == -ENOSPC)
-		unit = -EINVAL;
-	return unit;
+	ret = idr_alloc(p, ptr, NULL, n, n + 1, GFP_KERNEL);
+	if (ret == -ENOSPC)
+		ret = -EINVAL;
+	return ret;
 }
 
 /* get new free unit number and associate pointer with it */
-static int unit_get(struct idr *p, void *ptr)
+static int unit_get(struct idr *p, void *ptr, unsigned long *index)
 {
-	return idr_alloc(p, ptr, 0, 0, GFP_KERNEL);
+	return idr_alloc(p, ptr, index, 0, 0, GFP_KERNEL);
 }
 
 /* put unit number back to a pool */
diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 0d03941..7b306ab 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -408,6 +408,7 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
 {
 	int retval = -ENOMEM;
 	struct major_info *tap_major;
+	unsigned long idr_index;
 
 	rcu_read_lock();
 	tap_major = tap_get_major(MAJOR(major));
@@ -417,9 +418,10 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
 	}
 
 	spin_lock(&tap_major->minor_lock);
-	retval = idr_alloc(&tap_major->minor_idr, tap, 1, TAP_NUM_DEVS, GFP_ATOMIC);
-	if (retval >= 0) {
-		tap->minor = retval;
+	retval = idr_alloc(&tap_major->minor_idr, tap, &idr_index,
+			   1, TAP_NUM_DEVS, GFP_ATOMIC);
+	if (retval == 0) {
+		tap->minor = idr_index;
 	} else if (retval == -ENOSPC) {
 		netdev_err(tap->dev, "Too many tap devices\n");
 		retval = -EINVAL;
@@ -428,7 +430,7 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
 
 unlock:
 	rcu_read_unlock();
-	return retval < 0 ? retval : 0;
+	return retval;
 }
 EXPORT_SYMBOL_GPL(tap_get_minor);
 
diff --git a/drivers/net/wireless/ath/ath10k/htt.h b/drivers/net/wireless/ath/ath10k/htt.h
index 6305308..dddb9ed 100644
--- a/drivers/net/wireless/ath/ath10k/htt.h
+++ b/drivers/net/wireless/ath/ath10k/htt.h
@@ -1826,7 +1826,8 @@ void ath10k_htt_tx_txq_recalc(struct ieee80211_hw *hw,
 int ath10k_htt_tx_mgmt_inc_pending(struct ath10k_htt *htt, bool is_mgmt,
 				   bool is_presp);
 
-int ath10k_htt_tx_alloc_msdu_id(struct ath10k_htt *htt, struct sk_buff *skb);
+int ath10k_htt_tx_alloc_msdu_id(struct ath10k_htt *htt, struct sk_buff *skb,
+				unsigned long *index);
 void ath10k_htt_tx_free_msdu_id(struct ath10k_htt *htt, u16 msdu_id);
 int ath10k_htt_mgmt_tx(struct ath10k_htt *htt, struct sk_buff *msdu);
 int ath10k_htt_tx(struct ath10k_htt *htt,
diff --git a/drivers/net/wireless/ath/ath10k/htt_tx.c b/drivers/net/wireless/ath/ath10k/htt_tx.c
index 685faac..ab7e458 100644
--- a/drivers/net/wireless/ath/ath10k/htt_tx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_tx.c
@@ -203,14 +203,15 @@ void ath10k_htt_tx_mgmt_dec_pending(struct ath10k_htt *htt)
 	htt->num_pending_mgmt_tx--;
 }
 
-int ath10k_htt_tx_alloc_msdu_id(struct ath10k_htt *htt, struct sk_buff *skb)
+int ath10k_htt_tx_alloc_msdu_id(struct ath10k_htt *htt, struct sk_buff *skb,
+				unsigned long *index)
 {
 	struct ath10k *ar = htt->ar;
 	int ret;
 
 	lockdep_assert_held(&htt->tx_lock);
 
-	ret = idr_alloc(&htt->pending_tx, skb, 0,
+	ret = idr_alloc(&htt->pending_tx, skb, index, 0,
 			htt->max_num_pending_tx, GFP_ATOMIC);
 
 	ath10k_dbg(ar, ATH10K_DBG_HTT, "htt tx alloc msdu_id %d\n", ret);
@@ -423,7 +424,8 @@ int ath10k_htt_tx_start(struct ath10k_htt *htt)
 	return ret;
 }
 
-static int ath10k_htt_tx_clean_up_pending(int msdu_id, void *skb, void *ctx)
+static int ath10k_htt_tx_clean_up_pending(unsigned long msdu_id, void *skb,
+					  void *ctx)
 {
 	struct ath10k *ar = ctx;
 	struct ath10k_htt *htt = &ar->htt;
@@ -832,17 +834,18 @@ int ath10k_htt_mgmt_tx(struct ath10k_htt *htt, struct sk_buff *msdu)
 	int msdu_id = -1;
 	int res;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)msdu->data;
+	unsigned long idr_index;
 
 	len += sizeof(cmd->hdr);
 	len += sizeof(cmd->mgmt_tx);
 
 	spin_lock_bh(&htt->tx_lock);
-	res = ath10k_htt_tx_alloc_msdu_id(htt, msdu);
+	res = ath10k_htt_tx_alloc_msdu_id(htt, msdu, &idr_index);
 	spin_unlock_bh(&htt->tx_lock);
-	if (res < 0)
+	if (res)
 		goto err;
 
-	msdu_id = res;
+	msdu_id = idr_index;
 
 	if ((ieee80211_is_action(hdr->frame_control) ||
 	     ieee80211_is_deauth(hdr->frame_control) ||
@@ -917,14 +920,15 @@ int ath10k_htt_tx(struct ath10k_htt *htt, enum ath10k_hw_txrx_mode txmode,
 	u32 frags_paddr = 0;
 	u32 txbuf_paddr;
 	struct htt_msdu_ext_desc *ext_desc = NULL;
+	unsigned long idr_index;
 
 	spin_lock_bh(&htt->tx_lock);
-	res = ath10k_htt_tx_alloc_msdu_id(htt, msdu);
+	res = ath10k_htt_tx_alloc_msdu_id(htt, msdu, &idr_index);
 	spin_unlock_bh(&htt->tx_lock);
-	if (res < 0)
+	if (res)
 		goto err;
 
-	msdu_id = res;
+	msdu_id = idr_index;
 
 	prefetch_len = min(htt->prefetch_len, msdu->len);
 	prefetch_len = roundup(prefetch_len, 4);
diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index 55c808f..9d70725 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -3828,7 +3828,7 @@ static void ath10k_mac_txq_unref(struct ath10k *ar, struct ieee80211_txq *txq)
 	struct ath10k_txq *artxq;
 	struct ath10k_skb_cb *cb;
 	struct sk_buff *msdu;
-	int msdu_id;
+	unsigned long msdu_id;
 
 	if (!txq)
 		return;
diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index d67d700..f5151dd 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -820,23 +820,24 @@ struct sk_buff *
 {
 	struct sk_buff *orig_skb = skb;
 	struct mwifiex_txinfo *tx_info, *orig_tx_info;
+	unsigned long idr_index;
 
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (skb) {
 		unsigned long flags;
-		int id;
+		int ret;
 
 		spin_lock_irqsave(&priv->ack_status_lock, flags);
-		id = idr_alloc(&priv->ack_status_frames, orig_skb,
-			       1, 0x10, GFP_ATOMIC);
+		ret = idr_alloc(&priv->ack_status_frames, orig_skb, &idr_index,
+				1, 0x10, GFP_ATOMIC);
 		spin_unlock_irqrestore(&priv->ack_status_lock, flags);
 
-		if (id >= 0) {
+		if (ret == 0) {
 			tx_info = MWIFIEX_SKB_TXCB(skb);
-			tx_info->ack_frame_id = id;
+			tx_info->ack_frame_id = idr_index;
 			tx_info->flags |= flag;
 			orig_tx_info = MWIFIEX_SKB_TXCB(orig_skb);
-			orig_tx_info->ack_frame_id = id;
+			orig_tx_info->ack_frame_id = idr_index;
 			orig_tx_info->flags |= flag;
 
 			if (flag == MWIFIEX_BUF_FLAG_ACTION_TX_STATUS && cookie)
diff --git a/drivers/net/wireless/marvell/mwifiex/wmm.c b/drivers/net/wireless/marvell/mwifiex/wmm.c
index 0edd268..d4ad66b 100644
--- a/drivers/net/wireless/marvell/mwifiex/wmm.c
+++ b/drivers/net/wireless/marvell/mwifiex/wmm.c
@@ -562,7 +562,7 @@ static void mwifiex_wmm_delete_all_ralist(struct mwifiex_private *priv)
 	}
 }
 
-static int mwifiex_free_ack_frame(int id, void *p, void *data)
+static int mwifiex_free_ack_frame(unsigned long id, void *p, void *data)
 {
 	pr_warn("Have pending ack frames!\n");
 	kfree_skb(p);
diff --git a/drivers/of/overlay.c b/drivers/of/overlay.c
index c0e4ee1..e5cfe01 100644
--- a/drivers/of/overlay.c
+++ b/drivers/of/overlay.c
@@ -373,10 +373,11 @@ static int of_free_overlay_info(struct of_overlay *ov)
  *
  * Returns the id of the created overlay, or a negative error number
  */
-int of_overlay_create(struct device_node *tree)
+int of_overlay_create(struct device_node *tree, unsigned long *id)
 {
 	struct of_overlay *ov;
-	int err, id;
+	unsigned long idr_index;
+	int err;
 
 	/* allocate the overlay structure */
 	ov = kzalloc(sizeof(*ov), GFP_KERNEL);
@@ -390,12 +391,10 @@ int of_overlay_create(struct device_node *tree)
 
 	mutex_lock(&of_mutex);
 
-	id = idr_alloc(&ov_idr, ov, 0, 0, GFP_KERNEL);
-	if (id < 0) {
-		err = id;
+	err = idr_alloc(&ov_idr, ov, &idr_index, 0, 0, GFP_KERNEL);
+	if (err)
 		goto err_destroy_trans;
-	}
-	ov->id = id;
+	ov->id = idr_index;
 
 	/* build the overlay info structures */
 	err = of_build_overlay_info(ov, tree);
@@ -430,7 +429,7 @@ int of_overlay_create(struct device_node *tree)
 
 	mutex_unlock(&of_mutex);
 
-	return id;
+	return err;
 
 err_revert_overlay:
 err_abort_trans:
diff --git a/drivers/of/unittest.c b/drivers/of/unittest.c
index 0107fc6..ac7cc76 100644
--- a/drivers/of/unittest.c
+++ b/drivers/of/unittest.c
@@ -1242,7 +1242,8 @@ static int of_unittest_apply_overlay(int overlay_nr, int unittest_nr,
 		int *overlay_id)
 {
 	struct device_node *np = NULL;
-	int ret, id = -1;
+	unsigned long id = -1;
+	int ret;
 
 	np = of_find_node_by_path(overlay_path(overlay_nr));
 	if (np == NULL) {
@@ -1252,17 +1253,14 @@ static int of_unittest_apply_overlay(int overlay_nr, int unittest_nr,
 		goto out;
 	}
 
-	ret = of_overlay_create(np);
-	if (ret < 0) {
+	ret = of_overlay_create(np, &id);
+	if (ret) {
 		unittest(0, "could not create overlay from \"%s\"\n",
 				overlay_path(overlay_nr));
 		goto out;
 	}
-	id = ret;
 	of_unittest_track_overlay(id);
 
-	ret = 0;
-
 out:
 	of_node_put(np);
 
@@ -1442,6 +1440,7 @@ static void of_unittest_overlay_6(void)
 	int ret, i, ov_id[2];
 	int overlay_nr = 6, unittest_nr = 6;
 	int before = 0, after = 1;
+	unsigned long id;
 
 	/* unittest device must be in before state */
 	for (i = 0; i < 2; i++) {
@@ -1466,13 +1465,13 @@ static void of_unittest_overlay_6(void)
 			return;
 		}
 
-		ret = of_overlay_create(np);
-		if (ret < 0)  {
+		ret = of_overlay_create(np, &id);
+		if (ret)  {
 			unittest(0, "could not create overlay from \"%s\"\n",
 					overlay_path(overlay_nr + i));
 			return;
 		}
-		ov_id[i] = ret;
+		ov_id[i] = id;
 		of_unittest_track_overlay(ov_id[i]);
 	}
 
@@ -2094,6 +2093,7 @@ static int __init overlay_data_add(int onum)
 	int ret;
 	u32 size;
 	u32 size_from_header;
+	unsigned long id;
 
 	for (k = 0, info = overlays; info; info++, k++) {
 		if (k == onum)
@@ -2138,13 +2138,12 @@ static int __init overlay_data_add(int onum)
 		goto out_free_np_overlay;
 	}
 
-	ret = of_overlay_create(info->np_overlay);
-	if (ret < 0) {
+	ret = of_overlay_create(info->np_overlay, &id);
+	if (ret) {
 		pr_err("of_overlay_create() (ret=%d), %d\n", ret, onum);
 		goto out_free_np_overlay;
 	} else {
-		info->overlay_id = ret;
-		ret = 0;
+		info->overlay_id = id;
 	}
 
 	pr_debug("__dtb_overlay_begin applied, overlay id %d\n", ret);
diff --git a/drivers/power/supply/bq2415x_charger.c b/drivers/power/supply/bq2415x_charger.c
index c4770a9..268f099 100644
--- a/drivers/power/supply/bq2415x_charger.c
+++ b/drivers/power/supply/bq2415x_charger.c
@@ -1542,7 +1542,6 @@ static int bq2415x_probe(struct i2c_client *client,
 			 const struct i2c_device_id *id)
 {
 	int ret;
-	int num;
 	char *name = NULL;
 	struct bq2415x_device *bq;
 	struct device_node *np = client->dev.of_node;
@@ -1550,6 +1549,7 @@ static int bq2415x_probe(struct i2c_client *client,
 	const struct acpi_device_id *acpi_id = NULL;
 	struct power_supply *notify_psy = NULL;
 	union power_supply_propval prop;
+	unsigned long idr_index;
 
 	if (!np && !pdata && !ACPI_HANDLE(&client->dev)) {
 		dev_err(&client->dev, "Neither devicetree, nor platform data, nor ACPI support\n");
@@ -1558,13 +1558,13 @@ static int bq2415x_probe(struct i2c_client *client,
 
 	/* Get new ID for the new device */
 	mutex_lock(&bq2415x_id_mutex);
-	num = idr_alloc(&bq2415x_id, client, 0, 0, GFP_KERNEL);
+	ret = idr_alloc(&bq2415x_id, client, &idr_index, 0, 0, GFP_KERNEL);
 	mutex_unlock(&bq2415x_id_mutex);
-	if (num < 0)
-		return num;
+	if (ret)
+		return ret;
 
 	if (id) {
-		name = kasprintf(GFP_KERNEL, "%s-%d", id->name, num);
+		name = kasprintf(GFP_KERNEL, "%s-%d", id->name, idr_index);
 	} else if (ACPI_HANDLE(&client->dev)) {
 		acpi_id =
 			acpi_match_device(client->dev.driver->acpi_match_table,
@@ -1574,7 +1574,7 @@ static int bq2415x_probe(struct i2c_client *client,
 			ret = -ENODEV;
 			goto error_1;
 		}
-		name = kasprintf(GFP_KERNEL, "%s-%d", acpi_id->id, num);
+		name = kasprintf(GFP_KERNEL, "%s-%d", acpi_id->id, idr_index);
 	}
 	if (!name) {
 		dev_err(&client->dev, "failed to allocate device name\n");
@@ -1590,7 +1590,7 @@ static int bq2415x_probe(struct i2c_client *client,
 
 	i2c_set_clientdata(client, bq);
 
-	bq->id = num;
+	bq->id = idr_index;
 	bq->dev = &client->dev;
 	if (id)
 		bq->chip = id->driver_data;
@@ -1714,7 +1714,7 @@ static int bq2415x_probe(struct i2c_client *client,
 	kfree(name);
 error_1:
 	mutex_lock(&bq2415x_id_mutex);
-	idr_remove(&bq2415x_id, num);
+	idr_remove(&bq2415x_id, idr_index);
 	mutex_unlock(&bq2415x_id_mutex);
 
 	return ret;
diff --git a/drivers/power/supply/bq27xxx_battery_i2c.c b/drivers/power/supply/bq27xxx_battery_i2c.c
index a597221..6517416 100644
--- a/drivers/power/supply/bq27xxx_battery_i2c.c
+++ b/drivers/power/supply/bq27xxx_battery_i2c.c
@@ -148,18 +148,19 @@ static int bq27xxx_battery_i2c_probe(struct i2c_client *client,
 				     const struct i2c_device_id *id)
 {
 	struct bq27xxx_device_info *di;
+	unsigned long idr_index;
 	int ret;
 	char *name;
-	int num;
 
 	/* Get new ID for the new battery device */
 	mutex_lock(&battery_mutex);
-	num = idr_alloc(&battery_id, client, 0, 0, GFP_KERNEL);
+	ret = idr_alloc(&battery_id, client, &idr_index, 0, 0, GFP_KERNEL);
 	mutex_unlock(&battery_mutex);
-	if (num < 0)
-		return num;
+	if (ret)
+		return ret;
 
-	name = devm_kasprintf(&client->dev, GFP_KERNEL, "%s-%d", id->name, num);
+	name = devm_kasprintf(&client->dev, GFP_KERNEL, "%s-%d", id->name,
+			      idr_index);
 	if (!name)
 		goto err_mem;
 
@@ -167,7 +168,7 @@ static int bq27xxx_battery_i2c_probe(struct i2c_client *client,
 	if (!di)
 		goto err_mem;
 
-	di->id = num;
+	di->id = idr_index;
 	di->dev = &client->dev;
 	di->chip = id->driver_data;
 	di->name = name;
@@ -206,7 +207,7 @@ static int bq27xxx_battery_i2c_probe(struct i2c_client *client,
 
 err_failed:
 	mutex_lock(&battery_mutex);
-	idr_remove(&battery_id, num);
+	idr_remove(&battery_id, idr_index);
 	mutex_unlock(&battery_mutex);
 
 	return ret;
diff --git a/drivers/power/supply/ds2782_battery.c b/drivers/power/supply/ds2782_battery.c
index a1b7e05..19bf20b 100644
--- a/drivers/power/supply/ds2782_battery.c
+++ b/drivers/power/supply/ds2782_battery.c
@@ -380,6 +380,7 @@ static int ds278x_battery_probe(struct i2c_client *client,
 	struct ds278x_platform_data *pdata = client->dev.platform_data;
 	struct power_supply_config psy_cfg = {};
 	struct ds278x_info *info;
+	unsigned long idr_index;
 	int ret;
 	int num;
 
@@ -394,11 +395,11 @@ static int ds278x_battery_probe(struct i2c_client *client,
 
 	/* Get an ID for this battery */
 	mutex_lock(&battery_lock);
-	ret = idr_alloc(&battery_id, client, 0, 0, GFP_KERNEL);
+	ret = idr_alloc(&battery_id, client, &idr_index, 0, 0, GFP_KERNEL);
 	mutex_unlock(&battery_lock);
-	if (ret < 0)
+	if (ret)
 		goto fail_id;
-	num = ret;
+	num = idr_index;
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
@@ -446,7 +447,7 @@ static int ds278x_battery_probe(struct i2c_client *client,
 	kfree(info);
 fail_info:
 	mutex_lock(&battery_lock);
-	idr_remove(&battery_id, num);
+	idr_remove(&battery_id, idr_index);
 	mutex_unlock(&battery_lock);
 fail_id:
 	return ret;
diff --git a/drivers/powercap/powercap_sys.c b/drivers/powercap/powercap_sys.c
index 5b10b50..52a8493 100644
--- a/drivers/powercap/powercap_sys.c
+++ b/drivers/powercap/powercap_sys.c
@@ -502,6 +502,7 @@ struct powercap_zone *powercap_register_zone(
 {
 	int result;
 	int nr_attrs;
+	unsigned long idr_index;
 
 	if (!name || !control_type || !ops ||
 			nr_constraints > MAX_CONSTRAINTS_PER_ZONE ||
@@ -532,11 +533,12 @@ struct powercap_zone *powercap_register_zone(
 
 	mutex_lock(&control_type->lock);
 	/* Using idr to get the unique id */
-	result = idr_alloc(power_zone->parent_idr, NULL, 0, 0, GFP_KERNEL);
-	if (result < 0)
+	result = idr_alloc(power_zone->parent_idr, NULL, &idr_index, 0, 0,
+			   GFP_KERNEL);
+	if (result)
 		goto err_idr_alloc;
 
-	power_zone->id = result;
+	power_zone->id = idr_index;
 	idr_init(&power_zone->idr);
 	result = -ENOMEM;
 	power_zone->name = kstrdup(name, GFP_KERNEL);
diff --git a/drivers/pps/pps.c b/drivers/pps/pps.c
index 6eb0db3..cd167d2 100644
--- a/drivers/pps/pps.c
+++ b/drivers/pps/pps.c
@@ -354,14 +354,16 @@ int pps_register_cdev(struct pps_device *pps)
 {
 	int err;
 	dev_t devt;
+	unsigned long idr_index;
 
 	mutex_lock(&pps_idr_lock);
 	/*
 	 * Get new ID for the new PPS source.  After idr_alloc() calling
 	 * the new source will be freely available into the kernel.
 	 */
-	err = idr_alloc(&pps_idr, pps, 0, PPS_MAX_SOURCES, GFP_KERNEL);
-	if (err < 0) {
+	err = idr_alloc(&pps_idr, pps, &idr_index, 0, PPS_MAX_SOURCES,
+			GFP_KERNEL);
+	if (err) {
 		if (err == -ENOSPC) {
 			pr_err("%s: too many PPS sources in the system\n",
 			       pps->info.name);
@@ -369,7 +371,7 @@ int pps_register_cdev(struct pps_device *pps)
 		}
 		goto out_unlock;
 	}
-	pps->id = err;
+	pps->id = idr_index;
 	mutex_unlock(&pps_idr_lock);
 
 	devt = MKDEV(MAJOR(pps_devt), pps->id);
@@ -437,7 +439,7 @@ void pps_unregister_cdev(struct pps_device *pps)
 struct pps_device *pps_lookup_dev(void const *cookie)
 {
 	struct pps_device *pps;
-	unsigned id;
+	unsigned long id;
 
 	rcu_read_lock();
 	idr_for_each_entry(&pps_idr, pps, id)
diff --git a/drivers/rapidio/rio_cm.c b/drivers/rapidio/rio_cm.c
index bad0e0e..70310e9 100644
--- a/drivers/rapidio/rio_cm.c
+++ b/drivers/rapidio/rio_cm.c
@@ -1287,7 +1287,8 @@ static int riocm_ch_bind(u16 ch_id, u8 mport_id, void *context)
  */
 static struct rio_channel *riocm_ch_alloc(u16 ch_num)
 {
-	int id;
+	int ret;
+	unsigned long id;
 	int start, end;
 	struct rio_channel *ch;
 
@@ -1307,13 +1308,13 @@ static struct rio_channel *riocm_ch_alloc(u16 ch_num)
 
 	idr_preload(GFP_KERNEL);
 	spin_lock_bh(&idr_lock);
-	id = idr_alloc_cyclic(&ch_idr, ch, start, end, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&ch_idr, ch, &id, start, end, GFP_NOWAIT);
 	spin_unlock_bh(&idr_lock);
 	idr_preload_end();
 
-	if (id < 0) {
+	if (ret) {
 		kfree(ch);
-		return ERR_PTR(id == -ENOSPC ? -EBUSY : id);
+		return ERR_PTR(id == -ENOSPC ? -EBUSY : ret);
 	}
 
 	ch->id = (u16)id;
@@ -1501,7 +1502,7 @@ static int riocm_cdev_open(struct inode *inode, struct file *filp)
 static int riocm_cdev_release(struct inode *inode, struct file *filp)
 {
 	struct rio_channel *ch, *_c;
-	unsigned int i;
+	unsigned long i;
 	LIST_HEAD(list);
 
 	riocm_debug(EXIT, "by %s(%d) filp=%p",
@@ -1998,7 +1999,7 @@ static void riocm_remove_dev(struct device *dev, struct subsys_interface *sif)
 	struct cm_dev *cm;
 	struct cm_peer *peer;
 	struct rio_channel *ch, *_c;
-	unsigned int i;
+	unsigned long i;
 	bool found = false;
 	LIST_HEAD(list);
 
@@ -2179,7 +2180,7 @@ static void riocm_remove_mport(struct device *dev,
 	struct cm_dev *cm;
 	struct cm_peer *peer, *temp;
 	struct rio_channel *ch, *_c;
-	unsigned int i;
+	unsigned long i;
 	bool found = false;
 	LIST_HEAD(list);
 
@@ -2241,7 +2242,7 @@ static int rio_cm_shutdown(struct notifier_block *nb, unsigned long code,
 	void *unused)
 {
 	struct rio_channel *ch;
-	unsigned int i;
+	unsigned long i;
 	LIST_HEAD(list);
 
 	riocm_debug(EXIT, ".");
diff --git a/drivers/remoteproc/remoteproc_core.c b/drivers/remoteproc/remoteproc_core.c
index 564061d..63f2110 100644
--- a/drivers/remoteproc/remoteproc_core.c
+++ b/drivers/remoteproc/remoteproc_core.c
@@ -209,6 +209,7 @@ int rproc_alloc_vring(struct rproc_vdev *rvdev, int i)
 	dma_addr_t dma;
 	void *va;
 	int ret, size, notifyid;
+	unsigned long idr_index;
 
 	/* actual size of vring (in bytes) */
 	size = PAGE_ALIGN(vring_size(rvring->len, rvring->align));
@@ -228,13 +229,14 @@ int rproc_alloc_vring(struct rproc_vdev *rvdev, int i)
 	 * TODO: assign a notifyid for rvdev updates as well
 	 * TODO: support predefined notifyids (via resource table)
 	 */
-	ret = idr_alloc(&rproc->notifyids, rvring, 0, 0, GFP_KERNEL);
-	if (ret < 0) {
+	ret = idr_alloc(&rproc->notifyids, rvring, &idr_index, 0, 0,
+			GFP_KERNEL);
+	if (ret) {
 		dev_err(dev, "idr_alloc failed: %d\n", ret);
 		dma_free_coherent(dev->parent, size, va, dma);
 		return ret;
 	}
-	notifyid = ret;
+	notifyid = idr_index;
 
 	/* Potentially bump max_notifyid */
 	if (notifyid > rproc->max_notifyid)
diff --git a/drivers/rpmsg/virtio_rpmsg_bus.c b/drivers/rpmsg/virtio_rpmsg_bus.c
index eee2a9f..0074aec 100644
--- a/drivers/rpmsg/virtio_rpmsg_bus.c
+++ b/drivers/rpmsg/virtio_rpmsg_bus.c
@@ -221,6 +221,7 @@ static struct rpmsg_endpoint *__rpmsg_create_ept(struct virtproc_info *vrp,
 	int id_min, id_max, id;
 	struct rpmsg_endpoint *ept;
 	struct device *dev = rpdev ? &rpdev->dev : &vrp->vdev->dev;
+	unsigned long idr_index;
 
 	ept = kzalloc(sizeof(*ept), GFP_KERNEL);
 	if (!ept)
@@ -246,12 +247,13 @@ static struct rpmsg_endpoint *__rpmsg_create_ept(struct virtproc_info *vrp,
 	mutex_lock(&vrp->endpoints_lock);
 
 	/* bind the endpoint to an rpmsg address (and allocate one if needed) */
-	id = idr_alloc(&vrp->endpoints, ept, id_min, id_max, GFP_KERNEL);
-	if (id < 0) {
+	id = idr_alloc(&vrp->endpoints, ept, &idr_index, id_min, id_max,
+		       GFP_KERNEL);
+	if (id) {
 		dev_err(dev, "idr_alloc failed: %d\n", id);
 		goto free_ept;
 	}
-	ept->addr = id;
+	ept->addr = idr_index;
 
 	mutex_unlock(&vrp->endpoints_lock);
 
diff --git a/drivers/scsi/bfa/bfad_im.c b/drivers/scsi/bfa/bfad_im.c
index 7eb0eef..80b4aa8 100644
--- a/drivers/scsi/bfa/bfad_im.c
+++ b/drivers/scsi/bfa/bfad_im.c
@@ -554,15 +554,17 @@ static void bfad_im_fc_rport_add(struct bfad_im_port_s  *im_port,
 			struct device *dev)
 {
 	int error = 1;
+	unsigned long idr_index;
 
 	mutex_lock(&bfad_mutex);
-	error = idr_alloc(&bfad_im_port_index, im_port, 0, 0, GFP_KERNEL);
-	if (error < 0) {
+	error = idr_alloc(&bfad_im_port_index, im_port, &idr_index, 0, 0,
+			GFP_KERNEL);
+	if (error) {
 		mutex_unlock(&bfad_mutex);
 		printk(KERN_WARNING "idr_alloc failure\n");
 		goto out;
 	}
-	im_port->idr_id = error;
+	im_port->idr_id = idr_index;
 	mutex_unlock(&bfad_mutex);
 
 	im_port->shost = bfad_scsi_host_alloc(im_port, bfad);
diff --git a/drivers/scsi/ch.c b/drivers/scsi/ch.c
index dad959f..b155c9b 100644
--- a/drivers/scsi/ch.c
+++ b/drivers/scsi/ch.c
@@ -901,6 +901,7 @@ static int ch_probe(struct device *dev)
 	struct device *class_dev;
 	int ret;
 	scsi_changer *ch;
+	unsigned long idr_index;
 
 	if (sd->type != TYPE_MEDIUM_CHANGER)
 		return -ENODEV;
@@ -911,17 +912,18 @@ static int ch_probe(struct device *dev)
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&ch_index_lock);
-	ret = idr_alloc(&ch_index_idr, ch, 0, CH_MAX_DEVS + 1, GFP_NOWAIT);
+	ret = idr_alloc(&ch_index_idr, ch, &idr_index, 0, CH_MAX_DEVS + 1,
+			GFP_NOWAIT);
 	spin_unlock(&ch_index_lock);
 	idr_preload_end();
 
-	if (ret < 0) {
+	if (ret) {
 		if (ret == -ENOSPC)
 			ret = -ENODEV;
 		goto free_ch;
 	}
 
-	ch->minor = ret;
+	ch->minor = idr_index;
 	sprintf(ch->name,"ch%d",ch->minor);
 
 	class_dev = device_create(ch_sysfs_class, dev,
diff --git a/drivers/scsi/lpfc/lpfc_crtn.h b/drivers/scsi/lpfc/lpfc_crtn.h
index da669dc..b0d0307 100644
--- a/drivers/scsi/lpfc/lpfc_crtn.h
+++ b/drivers/scsi/lpfc/lpfc_crtn.h
@@ -410,7 +410,7 @@ void *lpfc_nvmet_buf_alloc(struct lpfc_hba *phba, int flags,
 int  lpfc_vport_disable(struct fc_vport *fc_vport, bool disable);
 int lpfc_mbx_unreg_vpi(struct lpfc_vport *);
 void destroy_port(struct lpfc_vport *);
-int lpfc_get_instance(void);
+int lpfc_get_instance(unsigned long *index);
 void lpfc_host_attrib_init(struct Scsi_Host *);
 
 extern void lpfc_debugfs_initialize(struct lpfc_vport *);
diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
index 491aa95..7e4bdad 100644
--- a/drivers/scsi/lpfc/lpfc_init.c
+++ b/drivers/scsi/lpfc/lpfc_init.c
@@ -3980,11 +3980,11 @@ struct lpfc_vport *
  *   -1 - lpfc get instance failed.
  **/
 int
-lpfc_get_instance(void)
+lpfc_get_instance(unsigned long *index)
 {
 	int ret;
 
-	ret = idr_alloc(&lpfc_hba_index, NULL, 0, 0, GFP_KERNEL);
+	ret = idr_alloc(&lpfc_hba_index, NULL, index, 0, 0, GFP_KERNEL);
 	return ret < 0 ? -1 : ret;
 }
 
@@ -6756,6 +6756,8 @@ struct lpfc_rpi_hdr *
 lpfc_hba_alloc(struct pci_dev *pdev)
 {
 	struct lpfc_hba *phba;
+	unsigned long idr_index;
+	int ret;
 
 	/* Allocate memory for HBA structure */
 	phba = kzalloc(sizeof(struct lpfc_hba), GFP_KERNEL);
@@ -6768,8 +6770,9 @@ struct lpfc_rpi_hdr *
 	phba->pcidev = pdev;
 
 	/* Assign an unused board number */
-	phba->brd_no = lpfc_get_instance();
-	if (phba->brd_no < 0) {
+	ret = lpfc_get_instance(&idr_index);
+	phba->brd_no = idr_index;
+	if (ret) {
 		kfree(phba);
 		return NULL;
 	}
diff --git a/drivers/scsi/lpfc/lpfc_vport.c b/drivers/scsi/lpfc/lpfc_vport.c
index c714482..a5968bd 100644
--- a/drivers/scsi/lpfc/lpfc_vport.c
+++ b/drivers/scsi/lpfc/lpfc_vport.c
@@ -299,10 +299,11 @@ static void lpfc_discovery_wait(struct lpfc_vport *vport)
 	struct lpfc_vport *pport = (struct lpfc_vport *) shost->hostdata;
 	struct lpfc_hba   *phba = pport->phba;
 	struct lpfc_vport *vport = NULL;
-	int instance;
+	int ret;
 	int vpi;
 	int rc = VPORT_ERROR;
 	int status;
+	unsigned long idr_index;
 
 	if ((phba->sli_rev < 3) || !(phba->cfg_enable_npiv)) {
 		lpfc_printf_log(phba, KERN_ERR, LOG_VPORT,
@@ -324,7 +325,8 @@ static void lpfc_discovery_wait(struct lpfc_vport *vport)
 	}
 
 	/* Assign an unused board number */
-	if ((instance = lpfc_get_instance()) < 0) {
+	ret = lpfc_get_instance(&idr_index);
+	if (ret) {
 		lpfc_printf_log(phba, KERN_ERR, LOG_VPORT,
 				"1810 Create VPORT failed: Cannot get "
 				"instance number\n");
@@ -333,7 +335,7 @@ static void lpfc_discovery_wait(struct lpfc_vport *vport)
 		goto error_out;
 	}
 
-	vport = lpfc_create_port(phba, instance, &fc_vport->dev);
+	vport = lpfc_create_port(phba, idr_index, &fc_vport->dev);
 	if (!vport) {
 		lpfc_printf_log(phba, KERN_ERR, LOG_VPORT,
 				"1811 Create VPORT failed: vpi x%x\n", vpi);
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index d7ff71e..82b71b7 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -1402,6 +1402,7 @@ static long sg_compat_ioctl(struct file *filp, unsigned int cmd_in, unsigned lon
 	unsigned long iflags;
 	int error;
 	u32 k;
+	unsigned long idr_index;
 
 	sdp = kzalloc(sizeof(Sg_device), GFP_KERNEL);
 	if (!sdp) {
@@ -1413,8 +1414,9 @@ static long sg_compat_ioctl(struct file *filp, unsigned int cmd_in, unsigned lon
 	idr_preload(GFP_KERNEL);
 	write_lock_irqsave(&sg_index_lock, iflags);
 
-	error = idr_alloc(&sg_index_idr, sdp, 0, SG_MAX_DEVS, GFP_NOWAIT);
-	if (error < 0) {
+	error = idr_alloc(&sg_index_idr, sdp, &idr_index, 0, SG_MAX_DEVS,
+			  GFP_NOWAIT);
+	if (error) {
 		if (error == -ENOSPC) {
 			sdev_printk(KERN_WARNING, scsidp,
 				    "Unable to attach sg device type=%d, minor number exceeds %d\n",
@@ -1427,7 +1429,7 @@ static long sg_compat_ioctl(struct file *filp, unsigned int cmd_in, unsigned lon
 		}
 		goto out_unlock;
 	}
-	k = error;
+	k = idr_index;
 
 	SCSI_LOG_TIMEOUT(3, sdev_printk(KERN_INFO, scsidp,
 					"sg_alloc: dev=%d \n", k));
@@ -2206,7 +2208,7 @@ static long sg_compat_ioctl(struct file *filp, unsigned int cmd_in, unsigned lon
 
 #ifdef CONFIG_SCSI_PROC_FS
 static int
-sg_idr_max_id(int id, void *p, void *data)
+sg_idr_max_id(unsigned long id, void *p, void *data)
 {
 	int *k = data;
 
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 8e5013d..f5a3db8 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -4261,6 +4261,7 @@ static int st_probe(struct device *dev)
 	struct st_buffer *buffer;
 	int i, error;
 	char *stp;
+	unsigned long idr_index;
 
 	if (SDp->type != TYPE_TAPE)
 		return -ENODEV;
@@ -4372,14 +4373,15 @@ static int st_probe(struct device *dev)
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&st_index_lock);
-	error = idr_alloc(&st_index_idr, tpnt, 0, ST_MAX_TAPES + 1, GFP_NOWAIT);
+	error = idr_alloc(&st_index_idr, tpnt, &idr_index,
+			  0, ST_MAX_TAPES + 1, GFP_NOWAIT);
 	spin_unlock(&st_index_lock);
 	idr_preload_end();
-	if (error < 0) {
+	if (error) {
 		pr_warn("st: idr allocation failed: %d\n", error);
 		goto out_put_queue;
 	}
-	tpnt->index = error;
+	tpnt->index = idr_index;
 	sprintf(disk->disk_name, "st%d", tpnt->index);
 	tpnt->stats = kzalloc(sizeof(struct scsi_tape_stats), GFP_KERNEL);
 	if (tpnt->stats == NULL) {
diff --git a/drivers/staging/greybus/uart.c b/drivers/staging/greybus/uart.c
index c6d01b8..1c81446 100644
--- a/drivers/staging/greybus/uart.c
+++ b/drivers/staging/greybus/uart.c
@@ -371,14 +371,16 @@ static struct gb_tty *get_gb_by_minor(unsigned int minor)
 
 static int alloc_minor(struct gb_tty *gb_tty)
 {
-	int minor;
+	int ret;
+	unsigned long idr_index;
 
 	mutex_lock(&table_lock);
-	minor = idr_alloc(&tty_minors, gb_tty, 0, GB_NUM_MINORS, GFP_KERNEL);
+	ret = idr_alloc(&tty_minors, gb_tty, &idr_index, 0, GB_NUM_MINORS,
+			GFP_KERNEL);
 	mutex_unlock(&table_lock);
-	if (minor >= 0)
-		gb_tty->minor = minor;
-	return minor;
+	if (ret == 0)
+		gb_tty->minor = idr_index;
+	return ret;
 }
 
 static void release_minor(struct gb_tty *gb_tty)
@@ -835,7 +837,6 @@ static int gb_uart_probe(struct gbphy_device *gbphy_dev,
 	struct gb_tty *gb_tty;
 	struct device *tty_dev;
 	int retval;
-	int minor;
 
 	gb_tty = kzalloc(sizeof(*gb_tty), GFP_KERNEL);
 	if (!gb_tty)
@@ -874,19 +875,16 @@ static int gb_uart_probe(struct gbphy_device *gbphy_dev,
 	gb_tty->credits = GB_UART_FIRMWARE_CREDITS;
 	init_completion(&gb_tty->credits_complete);
 
-	minor = alloc_minor(gb_tty);
-	if (minor < 0) {
-		if (minor == -ENOSPC) {
+	retval = alloc_minor(gb_tty);
+	if (retval) {
+		if (ret == -ENOSPC) {
 			dev_err(&gbphy_dev->dev,
 				"no more free minor numbers\n");
 			retval = -ENODEV;
-		} else {
-			retval = minor;
 		}
 		goto exit_kfifo_free;
 	}
 
-	gb_tty->minor = minor;
 	spin_lock_init(&gb_tty->write_lock);
 	spin_lock_init(&gb_tty->read_lock);
 	init_waitqueue_head(&gb_tty->wioctl);
diff --git a/drivers/staging/unisys/visorhba/visorhba_main.c b/drivers/staging/unisys/visorhba/visorhba_main.c
index a6e7a6b..9d246f7 100644
--- a/drivers/staging/unisys/visorhba/visorhba_main.c
+++ b/drivers/staging/unisys/visorhba/visorhba_main.c
@@ -243,15 +243,16 @@ static unsigned int simple_idr_get(struct idr *idrtable, void *p,
 {
 	int id;
 	unsigned long flags;
+	unsigned long idr_index;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock_irqsave(lock, flags);
-	id = idr_alloc(idrtable, p, 1, INT_MAX, GFP_NOWAIT);
+	id = idr_alloc(idrtable, p, &idr_index, 1, INT_MAX, GFP_NOWAIT);
 	spin_unlock_irqrestore(lock, flags);
 	idr_preload_end();
-	if (id < 0)
+	if (id)
 		return 0;  /* failure */
-	return (unsigned int)(id);  /* idr_alloc() guarantees > 0 */
+	return (unsigned int)(idr_index);  /* idr_alloc() guarantees > 0 */
 }
 
 /*
diff --git a/drivers/target/iscsi/iscsi_target.c b/drivers/target/iscsi/iscsi_target.c
index 74e4975..a43b8ba 100644
--- a/drivers/target/iscsi/iscsi_target.c
+++ b/drivers/target/iscsi/iscsi_target.c
@@ -120,6 +120,7 @@ void iscsit_put_tiqn_for_login(struct iscsi_tiqn *tiqn)
 struct iscsi_tiqn *iscsit_add_tiqn(unsigned char *buf)
 {
 	struct iscsi_tiqn *tiqn = NULL;
+	unsigned long idr_index;
 	int ret;
 
 	if (strlen(buf) >= ISCSI_IQN_LEN) {
@@ -146,15 +147,15 @@ struct iscsi_tiqn *iscsit_add_tiqn(unsigned char *buf)
 	idr_preload(GFP_KERNEL);
 	spin_lock(&tiqn_lock);
 
-	ret = idr_alloc(&tiqn_idr, NULL, 0, 0, GFP_NOWAIT);
-	if (ret < 0) {
+	ret = idr_alloc(&tiqn_idr, NULL, &idr_index, 0, 0, GFP_NOWAIT);
+	if (ret) {
 		pr_err("idr_alloc() failed for tiqn->tiqn_index\n");
 		spin_unlock(&tiqn_lock);
 		idr_preload_end();
 		kfree(tiqn);
 		return ERR_PTR(ret);
 	}
-	tiqn->tiqn_index = ret;
+	tiqn->tiqn_index = idr_index;
 	list_add_tail(&tiqn->tiqn_list, &g_tiqn_list);
 
 	spin_unlock(&tiqn_lock);
diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/iscsi/iscsi_target_login.c
index e9bdc8b..2283ecc 100644
--- a/drivers/target/iscsi/iscsi_target_login.c
+++ b/drivers/target/iscsi/iscsi_target_login.c
@@ -300,6 +300,7 @@ static int iscsi_login_zero_tsih_s1(
 {
 	struct iscsi_session *sess = NULL;
 	struct iscsi_login_req *pdu = (struct iscsi_login_req *)buf;
+	unsigned long idr_index;
 	int ret;
 
 	sess = kzalloc(sizeof(struct iscsi_session), GFP_KERNEL);
@@ -335,13 +336,13 @@ static int iscsi_login_zero_tsih_s1(
 
 	idr_preload(GFP_KERNEL);
 	spin_lock_bh(&sess_idr_lock);
-	ret = idr_alloc(&sess_idr, NULL, 0, 0, GFP_NOWAIT);
-	if (ret >= 0)
-		sess->session_index = ret;
+	ret = idr_alloc(&sess_idr, NULL, &idr_index, 0, 0, GFP_NOWAIT);
+	if (ret == 0)
+		sess->session_index = idr_index;
 	spin_unlock_bh(&sess_idr_lock);
 	idr_preload_end();
 
-	if (ret < 0) {
+	if (ret) {
 		pr_err("idr_alloc() for sess_idr failed\n");
 		iscsit_tx_login_rsp(conn, ISCSI_STATUS_CLS_TARGET_ERR,
 				ISCSI_LOGIN_STATUS_NO_RESOURCES);
diff --git a/drivers/target/target_core_device.c b/drivers/target/target_core_device.c
index e8dd6da..3b18cc4 100644
--- a/drivers/target/target_core_device.c
+++ b/drivers/target/target_core_device.c
@@ -908,7 +908,7 @@ struct devices_idr_iter {
 	void *data;
 };
 
-static int target_devices_idr_iter(int id, void *p, void *data)
+static int target_devices_idr_iter(unsigned long id, void *p, void *data)
 {
 	struct devices_idr_iter *iter = data;
 	struct se_device *dev = p;
@@ -951,7 +951,8 @@ int target_for_each_device(int (*fn)(struct se_device *dev, void *data),
 int target_configure_device(struct se_device *dev)
 {
 	struct se_hba *hba = dev->se_hba;
-	int ret, id;
+	unsigned long id;
+	int ret;
 
 	if (dev->dev_flags & DF_CONFIGURED) {
 		pr_err("se_dev->se_dev_ptr already set for storage"
@@ -968,9 +969,9 @@ int target_configure_device(struct se_device *dev)
 	 * Use cyclic to try and avoid collisions with devices
 	 * that were recently removed.
 	 */
-	id = idr_alloc_cyclic(&devices_idr, dev, 0, INT_MAX, GFP_KERNEL);
+	ret = idr_alloc_cyclic(&devices_idr, dev, &id, 0, INT_MAX, GFP_KERNEL);
 	mutex_unlock(&device_mutex);
-	if (id < 0) {
+	if (ret) {
 		ret = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 80ee130..43466cc 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -430,7 +430,8 @@ static struct tcmu_cmd *tcmu_alloc_cmd(struct se_cmd *se_cmd)
 	struct se_device *se_dev = se_cmd->se_dev;
 	struct tcmu_dev *udev = TCMU_DEV(se_dev);
 	struct tcmu_cmd *tcmu_cmd;
-	int cmd_id;
+	unsigned long cmd_id;
+	int ret;
 
 	tcmu_cmd = kmem_cache_zalloc(tcmu_cmd_cache, GFP_KERNEL);
 	if (!tcmu_cmd)
@@ -453,12 +454,12 @@ static struct tcmu_cmd *tcmu_alloc_cmd(struct se_cmd *se_cmd)
 
 	idr_preload(GFP_KERNEL);
 	spin_lock_irq(&udev->commands_lock);
-	cmd_id = idr_alloc(&udev->commands, tcmu_cmd, 0,
-		USHRT_MAX, GFP_NOWAIT);
+	ret = idr_alloc(&udev->commands, tcmu_cmd, &cmd_id, 0,
+			USHRT_MAX, GFP_NOWAIT);
 	spin_unlock_irq(&udev->commands_lock);
 	idr_preload_end();
 
-	if (cmd_id < 0) {
+	if (ret) {
 		tcmu_free_cmd(tcmu_cmd);
 		return NULL;
 	}
@@ -1028,7 +1029,7 @@ static unsigned int tcmu_handle_completions(struct tcmu_dev *udev)
 	return handled;
 }
 
-static int tcmu_check_expired_cmd(int id, void *p, void *data)
+static int tcmu_check_expired_cmd(unsigned long id, void *p, void *data)
 {
 	struct tcmu_cmd *cmd = p;
 
@@ -1577,7 +1578,7 @@ static void tcmu_destroy_device(struct se_device *dev)
 	struct tcmu_dev *udev = TCMU_DEV(dev);
 	struct tcmu_cmd *cmd;
 	bool all_expired = true;
-	int i;
+	unsigned long i;
 
 	del_timer_sync(&udev->timeout);
 
diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index d356d7f0..5f1e13a 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -106,6 +106,7 @@ struct tee_shm *tee_shm_alloc(struct tee_context *ctx, size_t size, u32 flags)
 	struct tee_device *teedev = ctx->teedev;
 	struct tee_shm_pool_mgr *poolm = NULL;
 	struct tee_shm *shm;
+	unsigned long idr_index;
 	void *ret;
 	int rc;
 
@@ -150,12 +151,13 @@ struct tee_shm *tee_shm_alloc(struct tee_context *ctx, size_t size, u32 flags)
 	}
 
 	mutex_lock(&teedev->mutex);
-	shm->id = idr_alloc(&teedev->idr, shm, 1, 0, GFP_KERNEL);
+	rc = idr_alloc(&teedev->idr, shm, &idr_index, 1, 0, GFP_KERNEL);
 	mutex_unlock(&teedev->mutex);
-	if (shm->id < 0) {
-		ret = ERR_PTR(shm->id);
+	if (rc) {
+		ret = ERR_PTR(rc);
 		goto err_pool_free;
 	}
+	shm->id = idr_index;
 
 	if (flags & TEE_SHM_DMA_BUF) {
 		DEFINE_DMA_BUF_EXPORT_INFO(exp_info);
diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
index ff04b7f..05a7e81 100644
--- a/drivers/uio/uio.c
+++ b/drivers/uio/uio.c
@@ -372,12 +372,13 @@ static void uio_dev_del_attributes(struct uio_device *idev)
 static int uio_get_minor(struct uio_device *idev)
 {
 	int retval = -ENOMEM;
+	unsigned long idr_index;
 
 	mutex_lock(&minor_lock);
-	retval = idr_alloc(&uio_idr, idev, 0, UIO_MAX_DEVICES, GFP_KERNEL);
-	if (retval >= 0) {
-		idev->minor = retval;
-		retval = 0;
+	retval = idr_alloc(&uio_idr, idev, &idr_index, 0, UIO_MAX_DEVICES,
+			   GFP_KERNEL);
+	if (retval == 0) {
+		idev->minor = idr_index;
 	} else if (retval == -ENOSPC) {
 		dev_err(idev->dev, "too many uio devices\n");
 		retval = -EINVAL;
diff --git a/drivers/usb/class/cdc-acm.c b/drivers/usb/class/cdc-acm.c
index 5e056064..7105336 100644
--- a/drivers/usb/class/cdc-acm.c
+++ b/drivers/usb/class/cdc-acm.c
@@ -97,15 +97,16 @@ static struct acm *acm_get_by_minor(unsigned int minor)
 /*
  * Try to find an available minor number and if found, associate it with 'acm'.
  */
-static int acm_alloc_minor(struct acm *acm)
+static int acm_alloc_minor(struct acm *acm, unsigned long *index)
 {
-	int minor;
+	int ret;
 
 	mutex_lock(&acm_minors_lock);
-	minor = idr_alloc(&acm_minors, acm, 0, ACM_TTY_MINORS, GFP_KERNEL);
+	ret = idr_alloc(&acm_minors, acm, index, 0, ACM_TTY_MINORS,
+			GFP_KERNEL);
 	mutex_unlock(&acm_minors_lock);
 
-	return minor;
+	return ret;
 }
 
 /* Release the minor number associated with 'acm'.  */
@@ -1219,7 +1220,6 @@ static int acm_probe(struct usb_interface *intf,
 	struct usb_device *usb_dev = interface_to_usbdev(intf);
 	struct usb_cdc_parsed_header h;
 	struct acm *acm;
-	int minor;
 	int ctrlsize, readsize;
 	u8 *buf;
 	int call_intf_num = -1;
@@ -1231,6 +1231,7 @@ static int acm_probe(struct usb_interface *intf,
 	struct device *tty_dev;
 	int rv = -ENOMEM;
 	int res;
+	unsigned long idr_index;
 
 	/* normal quirks */
 	quirks = (unsigned long)id->driver_info;
@@ -1388,8 +1389,8 @@ static int acm_probe(struct usb_interface *intf,
 	if (acm == NULL)
 		goto alloc_fail;
 
-	minor = acm_alloc_minor(acm);
-	if (minor < 0)
+	rv = acm_alloc_minor(acm, &idr_index);
+	if (rv)
 		goto alloc_fail1;
 
 	ctrlsize = usb_endpoint_maxp(epctrl);
@@ -1399,7 +1400,7 @@ static int acm_probe(struct usb_interface *intf,
 	acm->writesize = usb_endpoint_maxp(epwrite) * 20;
 	acm->control = control_interface;
 	acm->data = data_interface;
-	acm->minor = minor;
+	acm->minor = idr_index;
 	acm->dev = usb_dev;
 	if (h.usb_cdc_acm_descriptor)
 		acm->ctrl_caps = h.usb_cdc_acm_descriptor->bmCapabilities;
@@ -1538,7 +1539,7 @@ static int acm_probe(struct usb_interface *intf,
 	acm->nb_index = 0;
 	acm->nb_size = 0;
 
-	dev_info(&intf->dev, "ttyACM%d: USB ACM device\n", minor);
+	dev_info(&intf->dev, "ttyACM%ld: USB ACM device\n", idr_index);
 
 	acm->line.dwDTERate = cpu_to_le32(9600);
 	acm->line.bDataBits = 8;
@@ -1548,8 +1549,9 @@ static int acm_probe(struct usb_interface *intf,
 	usb_set_intfdata(data_interface, acm);
 
 	usb_get_intf(control_interface);
-	tty_dev = tty_port_register_device(&acm->port, acm_tty_driver, minor,
-			&control_interface->dev);
+	tty_dev = tty_port_register_device(&acm->port, acm_tty_driver,
+					   idr_index,
+					   &control_interface->dev);
 	if (IS_ERR(tty_dev)) {
 		rv = PTR_ERR(tty_dev);
 		goto alloc_fail8;
diff --git a/drivers/usb/core/devices.c b/drivers/usb/core/devices.c
index 55dea2e..bc2a969 100644
--- a/drivers/usb/core/devices.c
+++ b/drivers/usb/core/devices.c
@@ -605,7 +605,7 @@ static ssize_t usb_device_read(struct file *file, char __user *buf,
 	struct usb_bus *bus;
 	ssize_t ret, total_written = 0;
 	loff_t skip_bytes = *ppos;
-	int id;
+	unsigned long id;
 
 	if (*ppos < 0)
 		return -EINVAL;
diff --git a/drivers/usb/core/hcd.c b/drivers/usb/core/hcd.c
index ab1bb3b..43d04fb 100644
--- a/drivers/usb/core/hcd.c
+++ b/drivers/usb/core/hcd.c
@@ -1017,11 +1017,12 @@ static void usb_bus_init (struct usb_bus *bus)
 static int usb_register_bus(struct usb_bus *bus)
 {
 	int result = -E2BIG;
-	int busnum;
+	unsigned long busnum;
 
 	mutex_lock(&usb_bus_idr_lock);
-	busnum = idr_alloc(&usb_bus_idr, bus, 1, USB_MAXBUS, GFP_KERNEL);
-	if (busnum < 0) {
+	result = idr_alloc(&usb_bus_idr, bus, &busnum, 1, USB_MAXBUS,
+			   GFP_KERNEL);
+	if (result) {
 		pr_err("%s: failed to get bus number\n", usbcore_name);
 		goto error_find_busnum;
 	}
diff --git a/drivers/usb/mon/mon_main.c b/drivers/usb/mon/mon_main.c
index 4684734..2ab8228 100644
--- a/drivers/usb/mon/mon_main.c
+++ b/drivers/usb/mon/mon_main.c
@@ -349,7 +349,8 @@ struct mon_bus *mon_bus_lookup(unsigned int num)
 static int __init mon_init(void)
 {
 	struct usb_bus *ubus;
-	int rc, id;
+	int rc;
+	unsigned long id;
 
 	if ((rc = mon_text_init()) != 0)
 		goto err_text;
diff --git a/drivers/usb/serial/usb-serial.c b/drivers/usb/serial/usb-serial.c
index bb34f9f..a9bf11d 100644
--- a/drivers/usb/serial/usb-serial.c
+++ b/drivers/usb/serial/usb-serial.c
@@ -88,18 +88,19 @@ static int allocate_minors(struct usb_serial *serial, int num_ports)
 {
 	struct usb_serial_port *port;
 	unsigned int i, j;
-	int minor;
+	unsigned long idr_index;
+	int ret;
 
 	dev_dbg(&serial->interface->dev, "%s %d\n", __func__, num_ports);
 
 	mutex_lock(&table_lock);
 	for (i = 0; i < num_ports; ++i) {
 		port = serial->port[i];
-		minor = idr_alloc(&serial_minors, port, 0,
+		ret = idr_alloc(&serial_minors, port, &idr_index, 0,
 					USB_SERIAL_TTY_MINORS, GFP_KERNEL);
-		if (minor < 0)
+		if (ret)
 			goto error;
-		port->minor = minor;
+		port->minor = idr_index;
 		port->port_number = i;
 	}
 	serial->minors_reserved = 1;
@@ -110,7 +111,7 @@ static int allocate_minors(struct usb_serial *serial, int num_ports)
 	for (j = 0; j < i; ++j)
 		idr_remove(&serial_minors, serial->port[j]->minor);
 	mutex_unlock(&table_lock);
-	return minor;
+	return ret;
 }
 
 static void release_minors(struct usb_serial *serial)
diff --git a/drivers/vfio/vfio.c b/drivers/vfio/vfio.c
index 330d505..4ca1d55 100644
--- a/drivers/vfio/vfio.c
+++ b/drivers/vfio/vfio.c
@@ -268,9 +268,11 @@ void vfio_unregister_iommu_driver(const struct vfio_iommu_driver_ops *ops)
 /**
  * Group minor allocation/free - both called with vfio.group_lock held
  */
-static int vfio_alloc_group_minor(struct vfio_group *group)
+static int vfio_alloc_group_minor(struct vfio_group *group,
+				   unsigned long *index)
 {
-	return idr_alloc(&vfio.group_idr, group, 0, MINORMASK + 1, GFP_KERNEL);
+	return idr_alloc(&vfio.group_idr, group, index, 0, MINORMASK + 1,
+			 GFP_KERNEL);
 }
 
 static void vfio_free_group_minor(int minor)
@@ -324,7 +326,8 @@ static struct vfio_group *vfio_create_group(struct iommu_group *iommu_group)
 {
 	struct vfio_group *group, *tmp;
 	struct device *dev;
-	int ret, minor;
+	unsigned long minor;
+	int ret;
 
 	group = kzalloc(sizeof(*group), GFP_KERNEL);
 	if (!group)
@@ -369,10 +372,10 @@ static struct vfio_group *vfio_create_group(struct iommu_group *iommu_group)
 		}
 	}
 
-	minor = vfio_alloc_group_minor(group);
-	if (minor < 0) {
+	ret = vfio_alloc_group_minor(group, &minor);
+	if (ret) {
 		vfio_group_unlock_and_free(group);
-		return ERR_PTR(minor);
+		return ERR_PTR(ret);
 	}
 
 	dev = device_create(vfio.class, NULL,
diff --git a/fs/dlm/lock.c b/fs/dlm/lock.c
index 6df3322..3e44d7f 100644
--- a/fs/dlm/lock.c
+++ b/fs/dlm/lock.c
@@ -1184,6 +1184,7 @@ static void detach_lkb(struct dlm_lkb *lkb)
 static int create_lkb(struct dlm_ls *ls, struct dlm_lkb **lkb_ret)
 {
 	struct dlm_lkb *lkb;
+	unsigned long idr_index;
 	int rv;
 
 	lkb = dlm_allocate_lkb(ls);
@@ -1202,13 +1203,13 @@ static int create_lkb(struct dlm_ls *ls, struct dlm_lkb **lkb_ret)
 
 	idr_preload(GFP_NOFS);
 	spin_lock(&ls->ls_lkbidr_spin);
-	rv = idr_alloc(&ls->ls_lkbidr, lkb, 1, 0, GFP_NOWAIT);
-	if (rv >= 0)
-		lkb->lkb_id = rv;
+	rv = idr_alloc(&ls->ls_lkbidr, lkb, &idr_index, 1, 0, GFP_NOWAIT);
+	if (rv == 0)
+		lkb->lkb_id = idr_index;
 	spin_unlock(&ls->ls_lkbidr_spin);
 	idr_preload_end();
 
-	if (rv < 0) {
+	if (rv) {
 		log_error(ls, "create_lkb idr error %d", rv);
 		return rv;
 	}
diff --git a/fs/dlm/lockspace.c b/fs/dlm/lockspace.c
index 91592b7..830f2e2 100644
--- a/fs/dlm/lockspace.c
+++ b/fs/dlm/lockspace.c
@@ -717,19 +717,19 @@ int dlm_new_lockspace(const char *name, const char *cluster,
 	return error;
 }
 
-static int lkb_idr_is_local(int id, void *p, void *data)
+static int lkb_idr_is_local(unsigned long id, void *p, void *data)
 {
 	struct dlm_lkb *lkb = p;
 
 	return lkb->lkb_nodeid == 0 && lkb->lkb_grmode != DLM_LOCK_IV;
 }
 
-static int lkb_idr_is_any(int id, void *p, void *data)
+static int lkb_idr_is_any(unsigned long id, void *p, void *data)
 {
 	return 1;
 }
 
-static int lkb_idr_free(int id, void *p, void *data)
+static int lkb_idr_free(unsigned long id, void *p, void *data)
 {
 	struct dlm_lkb *lkb = p;
 
diff --git a/fs/dlm/recover.c b/fs/dlm/recover.c
index eaea789..6175536 100644
--- a/fs/dlm/recover.c
+++ b/fs/dlm/recover.c
@@ -305,6 +305,7 @@ static int recover_idr_empty(struct dlm_ls *ls)
 static int recover_idr_add(struct dlm_rsb *r)
 {
 	struct dlm_ls *ls = r->res_ls;
+	unsigned long idr_index;
 	int rv;
 
 	idr_preload(GFP_NOFS);
@@ -313,14 +314,13 @@ static int recover_idr_add(struct dlm_rsb *r)
 		rv = -1;
 		goto out_unlock;
 	}
-	rv = idr_alloc(&ls->ls_recover_idr, r, 1, 0, GFP_NOWAIT);
-	if (rv < 0)
+	rv = idr_alloc(&ls->ls_recover_idr, r, &idr_index, 1, 0, GFP_NOWAIT);
+	if (rv)
 		goto out_unlock;
 
-	r->res_id = rv;
+	r->res_id = idr_index;
 	ls->ls_recover_list_count++;
 	dlm_hold_rsb(r);
-	rv = 0;
 out_unlock:
 	spin_unlock(&ls->ls_recover_idr_lock);
 	idr_preload_end();
@@ -353,7 +353,7 @@ static struct dlm_rsb *recover_idr_find(struct dlm_ls *ls, uint64_t id)
 static void recover_idr_clear(struct dlm_ls *ls)
 {
 	struct dlm_rsb *r;
-	int id;
+	unsigned long id;
 
 	spin_lock(&ls->ls_recover_idr_lock);
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index e9bea90..7a45ccb 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -27,18 +27,19 @@
 static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 {
 	int ret = 0;
+	unsigned long idr_index;
 	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 
 	if (clp->rpc_ops->version != 4 || minorversion != 0)
 		return ret;
 	idr_preload(GFP_KERNEL);
 	spin_lock(&nn->nfs_client_lock);
-	ret = idr_alloc(&nn->cb_ident_idr, clp, 1, 0, GFP_NOWAIT);
-	if (ret >= 0)
-		clp->cl_cb_ident = ret;
+	ret = idr_alloc(&nn->cb_ident_idr, clp, &idr_index, 1, 0, GFP_NOWAIT);
+	if (ret == 0)
+		clp->cl_cb_ident = idr_index;
 	spin_unlock(&nn->nfs_client_lock);
 	idr_preload_end();
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 #ifdef CONFIG_NFS_V4_1
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81..cf14954 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -637,7 +637,8 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 				  void (*sc_free)(struct nfs4_stid *))
 {
 	struct nfs4_stid *stid;
-	int new_id;
+	unsigned long new_id;
+	int ret;
 
 	stid = kmem_cache_zalloc(slab, GFP_KERNEL);
 	if (!stid)
@@ -645,10 +646,11 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&cl->cl_lock);
-	new_id = idr_alloc_cyclic(&cl->cl_stateids, stid, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&cl->cl_stateids, stid, &new_id, 0, 0,
+				GFP_NOWAIT);
 	spin_unlock(&cl->cl_lock);
 	idr_preload_end();
-	if (new_id < 0)
+	if (ret)
 		goto out_free;
 
 	stid->sc_free = sc_free;
diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index 8b73332..4bc9b40 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -134,7 +134,7 @@ static void inotify_freeing_mark(struct fsnotify_mark *fsn_mark, struct fsnotify
  * torn down.  This is only called if the idr is about to be freed but there
  * are still marks in it.
  */
-static int idr_callback(int id, void *p, void *data)
+static int idr_callback(unsigned long id, void *p, void *data)
 {
 	struct fsnotify_mark *fsn_mark;
 	struct inotify_inode_mark *i_mark;
@@ -147,7 +147,7 @@ static int idr_callback(int id, void *p, void *data)
 	fsn_mark = p;
 	i_mark = container_of(fsn_mark, struct inotify_inode_mark, fsn_mark);
 
-	WARN(1, "inotify closing but id=%d for fsn_mark=%p in group=%p still in "
+	WARN(1, "inotify closing but id=%lu for fsn_mark=%p in group=%p still in "
 		"idr.  Probably leaking memory\n", id, p, data);
 
 	/*
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index 7cc7d3f..95915f8 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -345,20 +345,21 @@ static int inotify_add_to_idr(struct idr *idr, spinlock_t *idr_lock,
 			      struct inotify_inode_mark *i_mark)
 {
 	int ret;
+	unsigned long idr_index;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(idr_lock);
 
-	ret = idr_alloc_cyclic(idr, i_mark, 1, 0, GFP_NOWAIT);
-	if (ret >= 0) {
+	ret = idr_alloc_cyclic(idr, i_mark, &idr_index, 1, 0, GFP_NOWAIT);
+	if (ret == 0) {
 		/* we added the mark to the idr, take a reference */
-		i_mark->wd = ret;
+		i_mark->wd = idr_index;
 		fsnotify_get_mark(&i_mark->fsn_mark);
 	}
 
 	spin_unlock(idr_lock);
 	idr_preload_end();
-	return ret < 0 ? ret : 0;
+	return ret;
 }
 
 static struct inotify_inode_mark *inotify_idr_find_locked(struct fsnotify_group *group,
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index 8d77922..27ff262 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -306,15 +306,17 @@ static u8 o2net_num_from_nn(struct o2net_node *nn)
 static int o2net_prep_nsw(struct o2net_node *nn, struct o2net_status_wait *nsw)
 {
 	int ret;
+	unsigned long idr_index;
 
 	spin_lock(&nn->nn_lock);
-	ret = idr_alloc(&nn->nn_status_idr, nsw, 0, 0, GFP_ATOMIC);
-	if (ret >= 0) {
-		nsw->ns_id = ret;
+	ret = idr_alloc(&nn->nn_status_idr, nsw, &idr_index, 0, 0,
+			GFP_ATOMIC);
+	if (ret == 0) {
+		nsw->ns_id = idr_index;
 		list_add_tail(&nsw->ns_node_item, &nn->nn_status_list);
 	}
 	spin_unlock(&nn->nn_lock);
-	if (ret < 0)
+	if (ret)
 		return ret;
 
 	init_waitqueue_head(&nsw->ns_wq);
diff --git a/include/linux/idr.h b/include/linux/idr.h
index bf70b3e..1845576 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -18,7 +18,7 @@
 
 struct idr {
 	struct radix_tree_root	idr_rt;
-	unsigned int		idr_next;
+	unsigned long		idr_next;
 };
 
 /*
@@ -57,7 +57,7 @@ static inline unsigned int idr_get_cursor(const struct idr *idr)
  * The next call to idr_alloc_cyclic() will return @val if it is free
  * (otherwise the search will start from this position).
  */
-static inline void idr_set_cursor(struct idr *idr, unsigned int val)
+static inline void idr_set_cursor(struct idr *idr, unsigned long val)
 {
 	WRITE_ONCE(idr->idr_next, val);
 }
@@ -80,15 +80,17 @@ static inline void idr_set_cursor(struct idr *idr, unsigned int val)
  */
 
 void idr_preload(gfp_t gfp_mask);
-int idr_alloc(struct idr *, void *entry, int start, int end, gfp_t);
-int idr_alloc_cyclic(struct idr *, void *entry, int start, int end, gfp_t);
-int idr_for_each(const struct idr *,
-		 int (*fn)(int id, void *p, void *data), void *data);
-void *idr_get_next(struct idr *, int *nextid);
-void *idr_replace(struct idr *, void *, int id);
-void idr_destroy(struct idr *);
-
-static inline void *idr_remove(struct idr *idr, int id)
+int idr_alloc(struct idr *idr, void *ptr, unsigned long *index,
+	      unsigned long start, unsigned long end, gfp_t gfp);
+int idr_alloc_cyclic(struct idr *idr, void *entry, unsigned long *index,
+		     unsigned long start, unsigned long end, gfp_t gfp);
+int idr_for_each(const struct idr *idr,
+		 int (*fn)(unsigned long id, void *p, void *data), void *data);
+void *idr_get_next(struct idr *idr, unsigned long *nextid);
+void *idr_replace(struct idr *idr, void *ptr, unsigned long id);
+void idr_destroy(struct idr *idr);
+
+static inline void *idr_remove(struct idr *idr, unsigned long id)
 {
 	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
 }
@@ -128,7 +130,7 @@ static inline void idr_preload_end(void)
  * This function can be called under rcu_read_lock(), given that the leaf
  * pointers lifetimes are correctly managed.
  */
-static inline void *idr_find(const struct idr *idr, int id)
+static inline void *idr_find(const struct idr *idr, unsigned long id)
 {
 	return radix_tree_lookup(&idr->idr_rt, id);
 }
diff --git a/include/linux/of.h b/include/linux/of.h
index 4a8a709..ceb14bf 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -1307,7 +1307,7 @@ struct of_overlay_notify_data {
 #ifdef CONFIG_OF_OVERLAY
 
 /* ID based overlays; the API for external users */
-int of_overlay_create(struct device_node *tree);
+int of_overlay_create(struct device_node *tree, *unsigned long *id);
 int of_overlay_destroy(int id);
 int of_overlay_destroy_all(void);
 
@@ -1316,7 +1316,7 @@ struct of_overlay_notify_data {
 
 #else
 
-static inline int of_overlay_create(struct device_node *tree)
+static inline int of_overlay_create(struct device_node *tree, unsigned long *id)
 {
 	return -ENOTSUPP;
 }
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 3e57350..14874e2 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -358,7 +358,7 @@ int radix_tree_split(struct radix_tree_root *, unsigned long index,
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
 			unsigned new_order, void *);
 void __rcu **idr_get_free(struct radix_tree_root *, struct radix_tree_iter *,
-			gfp_t, int end);
+			gfp_t, unsigned long end);
 
 enum {
 	RADIX_TREE_ITER_TAG_MASK = 0x0f,	/* tag index in lower nybble */
diff --git a/include/net/9p/9p.h b/include/net/9p/9p.h
index b8eb51a..1bdc805 100644
--- a/include/net/9p/9p.h
+++ b/include/net/9p/9p.h
@@ -567,7 +567,7 @@ struct p9_fcall {
 
 struct p9_idpool *p9_idpool_create(void);
 void p9_idpool_destroy(struct p9_idpool *);
-int p9_idpool_get(struct p9_idpool *p);
+int p9_idpool_get(struct p9_idpool *p, int *index);
 void p9_idpool_put(int id, struct p9_idpool *p);
 int p9_idpool_check(int id, struct p9_idpool *p);
 
diff --git a/ipc/msg.c b/ipc/msg.c
index 2c38f10..31013ff 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -143,7 +143,7 @@ static int newque(struct ipc_namespace *ns, struct ipc_params *params)
 
 	/* ipc_addid() locks msq upon success. */
 	retval = ipc_addid(&msg_ids(ns), &msq->q_perm, ns->msg_ctlmni);
-	if (retval < 0) {
+	if (retval) {
 		call_rcu(&msq->q_perm.rcu, msg_rcu_free);
 		return retval;
 	}
diff --git a/ipc/sem.c b/ipc/sem.c
index 38371e9..5144ccd 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -514,7 +514,7 @@ static int newary(struct ipc_namespace *ns, struct ipc_params *params)
 	sma->sem_ctime = get_seconds();
 
 	retval = ipc_addid(&sem_ids(ns), &sma->sem_perm, ns->sc_semmni);
-	if (retval < 0) {
+	if (retval) {
 		call_rcu(&sma->sem_perm.rcu, sem_rcu_free);
 		return retval;
 	}
diff --git a/ipc/shm.c b/ipc/shm.c
index 8828b4c..037b21f 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -298,7 +298,7 @@ static void shm_close(struct vm_area_struct *vma)
 }
 
 /* Called with ns->shm_ids(ns).rwsem locked */
-static int shm_try_destroy_orphaned(int id, void *p, void *data)
+static int shm_try_destroy_orphaned(unsigned long id, void *p, void *data)
 {
 	struct ipc_namespace *ns = data;
 	struct kern_ipc_perm *ipcp = p;
@@ -599,7 +599,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	shp->shm_creator = current;
 
 	error = ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni);
-	if (error < 0)
+	if (error)
 		goto no_id;
 
 	list_add(&shp->shm_clist, &current->sysvshm.shm_clist);
diff --git a/ipc/util.c b/ipc/util.c
index 1a2cb02..5a46124 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -221,8 +221,9 @@ int ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int size)
 {
 	kuid_t euid;
 	kgid_t egid;
-	int id;
+	int ret;
 	int next_id = ids->next_id;
+	unsigned long idr_index;
 
 	if (size > IPCMNI)
 		size = IPCMNI;
@@ -242,14 +243,14 @@ int ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int size)
 	new->cuid = new->uid = euid;
 	new->gid = new->cgid = egid;
 
-	id = idr_alloc(&ids->ipcs_idr, new,
-		       (next_id < 0) ? 0 : ipcid_to_idx(next_id), 0,
-		       GFP_NOWAIT);
+	ret = idr_alloc(&ids->ipcs_idr, new, &idr_index,
+			(next_id < 0) ? 0 : ipcid_to_idx(next_id), 0,
+			GFP_NOWAIT);
 	idr_preload_end();
-	if (id < 0) {
+	if (ret) {
 		spin_unlock(&new->lock);
 		rcu_read_unlock();
-		return id;
+		return ret;
 	}
 
 	ids->in_use++;
@@ -263,8 +264,8 @@ int ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int size)
 		ids->next_id = -1;
 	}
 
-	new->id = ipc_buildid(id, new->seq);
-	return id;
+	new->id = ipc_buildid(idr_index, new->seq);
+	return ret;
 }
 
 /**
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index fbe09a0..ba6b485 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -169,18 +169,19 @@ static void bpf_map_uncharge_memlock(struct bpf_map *map)
 
 static int bpf_map_alloc_id(struct bpf_map *map)
 {
-	int id;
+	int ret;
+	unsigned long id;
 
 	spin_lock_bh(&map_idr_lock);
-	id = idr_alloc_cyclic(&map_idr, map, 1, INT_MAX, GFP_ATOMIC);
-	if (id > 0)
+	ret = idr_alloc_cyclic(&map_idr, map, &id, 1, INT_MAX, GFP_ATOMIC);
+	if (ret == 0)
 		map->id = id;
 	spin_unlock_bh(&map_idr_lock);
 
 	if (WARN_ON_ONCE(!id))
 		return -ENOSPC;
 
-	return id > 0 ? 0 : id;
+	return ret;
 }
 
 static void bpf_map_free_id(struct bpf_map *map, bool do_idr_lock)
@@ -771,11 +772,12 @@ static void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
 
 static int bpf_prog_alloc_id(struct bpf_prog *prog)
 {
-	int id;
+	int ret;
+	unsigned long id;
 
 	spin_lock_bh(&prog_idr_lock);
-	id = idr_alloc_cyclic(&prog_idr, prog, 1, INT_MAX, GFP_ATOMIC);
-	if (id > 0)
+	ret = idr_alloc_cyclic(&prog_idr, prog, &id, 1, INT_MAX, GFP_ATOMIC);
+	if (ret == 0)
 		prog->aux->id = id;
 	spin_unlock_bh(&prog_idr_lock);
 
@@ -783,7 +785,7 @@ static int bpf_prog_alloc_id(struct bpf_prog *prog)
 	if (WARN_ON_ONCE(!id))
 		return -ENOSPC;
 
-	return id > 0 ? 0 : id;
+	return ret;
 }
 
 static void bpf_prog_free_id(struct bpf_prog *prog, bool do_idr_lock)
@@ -1202,7 +1204,7 @@ static int bpf_obj_get_next_id(const union bpf_attr *attr,
 			       struct idr *idr,
 			       spinlock_t *lock)
 {
-	u32 next_id = attr->start_id;
+	unsigned long next_id = attr->start_id;
 	int err = 0;
 
 	if (CHECK_ATTR(BPF_OBJ_GET_NEXT_ID) || next_id >= INT_MAX)
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index df2e0f1..1d774c2 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -286,15 +286,18 @@ bool cgroup_on_dfl(const struct cgroup *cgrp)
 }
 
 /* IDR wrappers which synchronize using cgroup_idr_lock */
-static int cgroup_idr_alloc(struct idr *idr, void *ptr, int start, int end,
-			    gfp_t gfp_mask)
+static int cgroup_idr_alloc(struct idr *idr, void *ptr, int *index,
+			    int start, int end, gfp_t gfp_mask)
 {
 	int ret;
+	unsigned long idr_index;
 
 	idr_preload(gfp_mask);
 	spin_lock_bh(&cgroup_idr_lock);
-	ret = idr_alloc(idr, ptr, start, end, gfp_mask & ~__GFP_DIRECT_RECLAIM);
+	ret = idr_alloc(idr, ptr, &idr_index, start, end,
+			gfp_mask & ~__GFP_DIRECT_RECLAIM);
 	spin_unlock_bh(&cgroup_idr_lock);
+	*index = idr_index;
 	idr_preload_end();
 	return ret;
 }
@@ -1040,13 +1043,15 @@ struct cgroup_root *cgroup_root_from_kf(struct kernfs_root *kf_root)
 
 static int cgroup_init_root_id(struct cgroup_root *root)
 {
-	int id;
+	int ret;
+	unsigned long id;
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, 0, 0, GFP_KERNEL);
-	if (id < 0)
-		return id;
+	ret = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, &id, 0, 0,
+			       GFP_KERNEL);
+	if (ret)
+		return ret;
 
 	root->hierarchy_id = id;
 	return 0;
@@ -1703,14 +1708,15 @@ int cgroup_setup_root(struct cgroup_root *root, u16 ss_mask, int ref_flags)
 	struct cgroup *root_cgrp = &root->cgrp;
 	struct kernfs_syscall_ops *kf_sops;
 	struct css_set *cset;
-	int i, ret;
+	int i, ret, index;
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	ret = cgroup_idr_alloc(&root->cgroup_idr, root_cgrp, 1, 2, GFP_KERNEL);
-	if (ret < 0)
+	ret = cgroup_idr_alloc(&root->cgroup_idr, root_cgrp, &index, 1, 2,
+			       GFP_KERNEL);
+	if (ret)
 		goto out;
-	root_cgrp->id = ret;
+	root_cgrp->id = index;
 	root_cgrp->ancestor_ids[0] = ret;
 
 	ret = percpu_ref_init(&root_cgrp->self.refcnt, css_release,
@@ -1955,7 +1961,7 @@ int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 {
 	struct cgroup_root *root;
 	struct cgroup *cgrp;
-	int hierarchy_id = 1;
+	unsigned long hierarchy_id = 1;
 	int ret;
 
 	mutex_lock(&cgroup_mutex);
@@ -4127,7 +4133,7 @@ static struct cgroup_subsys_state *css_create(struct cgroup *cgrp,
 	struct cgroup *parent = cgroup_parent(cgrp);
 	struct cgroup_subsys_state *parent_css = cgroup_css(parent, ss);
 	struct cgroup_subsys_state *css;
-	int err;
+	int err, index;
 
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -4143,10 +4149,10 @@ static struct cgroup_subsys_state *css_create(struct cgroup *cgrp,
 	if (err)
 		goto err_free_css;
 
-	err = cgroup_idr_alloc(&ss->css_idr, NULL, 2, 0, GFP_KERNEL);
-	if (err < 0)
+	err = cgroup_idr_alloc(&ss->css_idr, NULL, &index, 2, 0, GFP_KERNEL);
+	if (err)
 		goto err_free_css;
-	css->id = err;
+	css->id = index;
 
 	/* @css is ready to be brought online now, make it visible */
 	list_add_tail_rcu(&css->sibling, &parent_css->children);
@@ -4200,8 +4206,10 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	 * Temporarily set the pointer to NULL, so idr_find() won't return
 	 * a half-baked cgroup.
 	 */
-	cgrp->id = cgroup_idr_alloc(&root->cgroup_idr, NULL, 2, 0, GFP_KERNEL);
-	if (cgrp->id < 0) {
+	ret = cgroup_idr_alloc(&root->cgroup_idr, NULL, &cgrp->id, 2, 0,
+			       GFP_KERNEL);
+
+	if (ret) {
 		ret = -ENOMEM;
 		goto out_cancel_ref;
 	}
@@ -4501,6 +4509,7 @@ int cgroup_rmdir(struct kernfs_node *kn)
 static void __init cgroup_init_subsys(struct cgroup_subsys *ss, bool early)
 {
 	struct cgroup_subsys_state *css;
+	int ret;
 
 	pr_debug("Initializing cgroup subsys %s\n", ss->name);
 
@@ -4526,8 +4535,9 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss, bool early)
 		/* allocation can't be done safely during early init */
 		css->id = 1;
 	} else {
-		css->id = cgroup_idr_alloc(&ss->css_idr, css, 1, 2, GFP_KERNEL);
-		BUG_ON(css->id < 0);
+		ret = cgroup_idr_alloc(&ss->css_idr, css, &css->id, 1, 2,
+				       GFP_KERNEL);
+		WARN_ON(ret);
 	}
 
 	/* Update the init_css_set to contain a subsys
@@ -4598,6 +4608,7 @@ int __init cgroup_init_early(void)
 int __init cgroup_init(void)
 {
 	struct cgroup_subsys *ss;
+	int ret;
 	int ssid;
 
 	BUILD_BUG_ON(CGROUP_SUBSYS_COUNT > 16);
@@ -4631,9 +4642,9 @@ int __init cgroup_init(void)
 			struct cgroup_subsys_state *css =
 				init_css_set.subsys[ss->id];
 
-			css->id = cgroup_idr_alloc(&ss->css_idr, css, 1, 2,
-						   GFP_KERNEL);
-			BUG_ON(css->id < 0);
+			ret = cgroup_idr_alloc(&ss->css_idr, css, &css->id,
+					       1, 2, GFP_KERNEL);
+			WARN_ON(ret);
 		} else {
 			cgroup_init_subsys(ss, false);
 		}
diff --git a/kernel/events/core.c b/kernel/events/core.c
index a7a6c1d..4cb50bb 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -9013,6 +9013,7 @@ static int pmu_dev_alloc(struct pmu *pmu)
 int perf_pmu_register(struct pmu *pmu, const char *name, int type)
 {
 	int cpu, ret;
+	unsigned long idr_index;
 
 	mutex_lock(&pmus_lock);
 	ret = -ENOMEM;
@@ -9026,13 +9027,12 @@ int perf_pmu_register(struct pmu *pmu, const char *name, int type)
 	pmu->name = name;
 
 	if (type < 0) {
-		type = idr_alloc(&pmu_idr, pmu, PERF_TYPE_MAX, 0, GFP_KERNEL);
-		if (type < 0) {
-			ret = type;
+		ret = idr_alloc(&pmu_idr, pmu, &idr_index, PERF_TYPE_MAX, 0,
+				GFP_KERNEL);
+		if (ret)
 			goto free_pdc;
-		}
 	}
-	pmu->type = type;
+	pmu->type = idr_index;
 
 	if (pmu_bus_running) {
 		ret = pmu_dev_alloc(pmu);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ca937b0..213b338 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -533,13 +533,14 @@ static inline void debug_work_deactivate(struct work_struct *work) { }
 static int worker_pool_assign_id(struct worker_pool *pool)
 {
 	int ret;
+	unsigned long idr_index;
 
 	lockdep_assert_held(&wq_pool_mutex);
 
-	ret = idr_alloc(&worker_pool_idr, pool, 0, WORK_OFFQ_POOL_NONE,
-			GFP_KERNEL);
-	if (ret >= 0) {
-		pool->id = ret;
+	ret = idr_alloc(&worker_pool_idr, pool, &idr_index, 0,
+			WORK_OFFQ_POOL_NONE, GFP_KERNEL);
+	if (ret == 0) {
+		pool->id = idr_index;
 		return 0;
 	}
 	return ret;
@@ -4427,7 +4428,7 @@ void show_workqueue_state(void)
 	struct workqueue_struct *wq;
 	struct worker_pool *pool;
 	unsigned long flags;
-	int pi;
+	unsigned long pi;
 
 	rcu_read_lock_sched();
 
@@ -4674,7 +4675,7 @@ int workqueue_online_cpu(unsigned int cpu)
 {
 	struct worker_pool *pool;
 	struct workqueue_struct *wq;
-	int pi;
+	unsigned long pi;
 
 	mutex_lock(&wq_pool_mutex);
 
@@ -5380,7 +5381,7 @@ static void wq_watchdog_timer_fn(unsigned long data)
 	unsigned long thresh = READ_ONCE(wq_watchdog_thresh) * HZ;
 	bool lockup_detected = false;
 	struct worker_pool *pool;
-	int pi;
+	unsigned long pi;
 
 	if (!thresh)
 		return;
diff --git a/lib/idr.c b/lib/idr.c
index b13682b..e941cd1 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -11,12 +11,13 @@
  * idr_alloc - allocate an id
  * @idr: idr handle
  * @ptr: pointer to be associated with the new id
+ * @index: pointer to return allocated id, could be NULL
  * @start: the minimum id (inclusive)
  * @end: the maximum id (exclusive)
  * @gfp: memory allocation flags
  *
  * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
- * if there are no unused IDs in that range.
+ * if there are no unused IDs in that range.  Return 0 for success.
  *
  * Note that @end is treated as max when <= 0.  This is to always allow
  * using @start + N as @end as long as N is inside integer range.
@@ -26,13 +27,12 @@
  * concurrently with read-only accesses to the @idr, such as idr_find() and
  * idr_for_each_entry().
  */
-int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+int idr_alloc(struct idr *idr, void *ptr, unsigned long *index,
+	      unsigned long start, unsigned long end, gfp_t gfp)
 {
 	void __rcu **slot;
 	struct radix_tree_iter iter;
 
-	if (WARN_ON_ONCE(start < 0))
-		return -EINVAL;
 	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
 		return -EINVAL;
 
@@ -43,7 +43,10 @@ int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 
 	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
 	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
-	return iter.index;
+
+	if (index)
+		*index = iter.index;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(idr_alloc);
 
@@ -51,6 +54,7 @@ int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
  * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
  * @idr: idr handle
  * @ptr: pointer to be associated with the new id
+ * @index: pointer to return allocated id, could be NULL
  * @start: the minimum id (inclusive)
  * @end: the maximum id (exclusive)
  * @gfp: memory allocation flags
@@ -59,21 +63,23 @@ int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
  * If not, it will attempt to allocate the smallest ID that is larger or
  * equal to @start.
  */
-int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+int idr_alloc_cyclic(struct idr *idr, void *ptr, unsigned long *index,
+		     unsigned long start, unsigned long end, gfp_t gfp)
 {
-	int id, curr = idr->idr_next;
+	int ret;
+	unsigned long curr = idr->idr_next;
 
 	if (curr < start)
 		curr = start;
 
-	id = idr_alloc(idr, ptr, curr, end, gfp);
-	if ((id == -ENOSPC) && (curr > start))
-		id = idr_alloc(idr, ptr, start, curr, gfp);
+	ret = idr_alloc(idr, ptr, index, curr, end, gfp);
+	if (ret == -ENOSPC && curr > start)
+		ret = idr_alloc(idr, ptr, index, start, curr, gfp);
 
-	if (id >= 0)
-		idr->idr_next = id + 1U;
+	if (*index >= 0)
+		idr->idr_next = *index + 1UL;
 
-	return id;
+	return ret;
 }
 EXPORT_SYMBOL(idr_alloc_cyclic);
 
@@ -95,7 +101,7 @@ int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
  * will not cause other entries to be skipped, nor spurious ones to be seen.
  */
 int idr_for_each(const struct idr *idr,
-		int (*fn)(int id, void *p, void *data), void *data)
+		 int (*fn)(unsigned long id, void *p, void *data), void *data)
 {
 	struct radix_tree_iter iter;
 	void __rcu **slot;
@@ -120,7 +126,7 @@ int idr_for_each(const struct idr *idr,
  * to the ID of the found value.  To use in a loop, the value pointed to by
  * nextid must be incremented by the user.
  */
-void *idr_get_next(struct idr *idr, int *nextid)
+void *idr_get_next(struct idr *idr, unsigned long *nextid)
 {
 	struct radix_tree_iter iter;
 	void __rcu **slot;
@@ -148,7 +154,7 @@ void *idr_get_next(struct idr *idr, int *nextid)
  * Returns: 0 on success.  %-ENOENT indicates that @id was not found.
  * %-EINVAL indicates that @id or @ptr were not valid.
  */
-void *idr_replace(struct idr *idr, void *ptr, int id)
+void *idr_replace(struct idr *idr, void *ptr, unsigned long id)
 {
 	struct radix_tree_node *node;
 	void __rcu **slot = NULL;
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 898e879..87d8748 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -2138,12 +2138,13 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 EXPORT_SYMBOL(ida_pre_get);
 
 void __rcu **idr_get_free(struct radix_tree_root *root,
-			struct radix_tree_iter *iter, gfp_t gfp, int end)
+			   struct radix_tree_iter *iter, gfp_t gfp,
+			   unsigned long end)
 {
 	struct radix_tree_node *node = NULL, *child;
 	void __rcu **slot = (void __rcu **)&root->rnode;
 	unsigned long maxindex, start = iter->next_index;
-	unsigned long max = end > 0 ? end - 1 : INT_MAX;
+	unsigned long max = end - 1;
 	unsigned int shift, offset = 0;
 
  grow:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3df3c04..5b310ec 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4166,6 +4166,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	struct mem_cgroup *memcg;
 	size_t size;
 	int node;
+	unsigned long idr_index;
+	int ret;
 
 	size = sizeof(struct mem_cgroup);
 	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
@@ -4174,11 +4176,12 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg)
 		return NULL;
 
-	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
-				 1, MEM_CGROUP_ID_MAX,
-				 GFP_KERNEL);
-	if (memcg->id.id < 0)
+	ret = idr_alloc(&mem_cgroup_idr, NULL,
+			&idr_index, 1, MEM_CGROUP_ID_MAX,
+			GFP_KERNEL);
+	if (ret)
 		goto fail;
+	memcg->id.id = idr_index;
 
 	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat)
diff --git a/net/9p/client.c b/net/9p/client.c
index 4674235..484de6e6 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -361,14 +361,15 @@ struct p9_req_t *p9_tag_lookup(struct p9_client *c, u16 tag)
 static int p9_tag_init(struct p9_client *c)
 {
 	int err = 0;
+	int index;
 
 	c->tagpool = p9_idpool_create();
 	if (IS_ERR(c->tagpool)) {
 		err = PTR_ERR(c->tagpool);
 		goto error;
 	}
-	err = p9_idpool_get(c->tagpool); /* reserve tag 0 */
-	if (err < 0) {
+	err = p9_idpool_get(c->tagpool, &index); /* reserve tag 0 */
+	if (err) {
 		p9_idpool_destroy(c->tagpool);
 		goto error;
 	}
@@ -714,8 +715,8 @@ static struct p9_req_t *p9_client_prepare_req(struct p9_client *c,
 
 	tag = P9_NOTAG;
 	if (type != P9_TVERSION) {
-		tag = p9_idpool_get(c->tagpool);
-		if (tag < 0)
+		err = p9_idpool_get(c->tagpool, &tag);
+		if (err)
 			return ERR_PTR(-ENOMEM);
 	}
 
@@ -905,7 +906,7 @@ static struct p9_req_t *p9_client_zc_rpc(struct p9_client *c, int8_t type,
 
 static struct p9_fid *p9_fid_create(struct p9_client *clnt)
 {
-	int ret;
+	int ret, index;
 	struct p9_fid *fid;
 	unsigned long flags;
 
@@ -914,12 +915,12 @@ static struct p9_fid *p9_fid_create(struct p9_client *clnt)
 	if (!fid)
 		return ERR_PTR(-ENOMEM);
 
-	ret = p9_idpool_get(clnt->fidpool);
-	if (ret < 0) {
+	ret = p9_idpool_get(clnt->fidpool, &index);
+	if (ret) {
 		ret = -ENOSPC;
 		goto error;
 	}
-	fid->fid = ret;
+	fid->fid = index;
 
 	memset(&fid->qid, 0, sizeof(struct p9_qid));
 	fid->mode = -1;
diff --git a/net/9p/util.c b/net/9p/util.c
index 59f278e..328fdcb 100644
--- a/net/9p/util.c
+++ b/net/9p/util.c
@@ -85,24 +85,26 @@ void p9_idpool_destroy(struct p9_idpool *p)
  *            the lock included in struct idr?
  */
 
-int p9_idpool_get(struct p9_idpool *p)
+int p9_idpool_get(struct p9_idpool *p, int *index)
 {
-	int i;
+	int ret;
+	unsigned long idr_index;
 	unsigned long flags;
 
 	idr_preload(GFP_NOFS);
 	spin_lock_irqsave(&p->lock, flags);
 
 	/* no need to store exactly p, we just need something non-null */
-	i = idr_alloc(&p->pool, p, 0, 0, GFP_NOWAIT);
+	ret = idr_alloc(&p->pool, p, &idr_index, 0, 0, GFP_NOWAIT);
+	*index = idr_index;
 
 	spin_unlock_irqrestore(&p->lock, flags);
 	idr_preload_end();
-	if (i < 0)
+	if (ret)
 		return -1;
 
-	p9_debug(P9_DEBUG_MUX, " id %d pool %p\n", i, p);
-	return i;
+	p9_debug(P9_DEBUG_MUX, " ret %d id %d pool %p\n", ret, *index, p);
+	return ret;
 }
 EXPORT_SYMBOL(p9_idpool_get);
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6cfdc7c..a1cee8a 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -156,7 +156,8 @@ static void ops_free_list(const struct pernet_operations *ops,
 }
 
 /* should be called with nsid_lock held */
-static int alloc_netid(struct net *net, struct net *peer, int reqid)
+static int alloc_netid(struct net *net, struct net *peer, int reqid,
+		       unsigned long *index)
 {
 	int min = 0, max = 0;
 
@@ -165,7 +166,7 @@ static int alloc_netid(struct net *net, struct net *peer, int reqid)
 		max = reqid + 1;
 	}
 
-	return idr_alloc(&net->netns_ids, peer, min, max, GFP_ATOMIC);
+	return idr_alloc(&net->netns_ids, peer, index, min, max, GFP_ATOMIC);
 }
 
 /* This function is used by idr_for_each(). If net is equal to peer, the
@@ -174,7 +175,7 @@ static int alloc_netid(struct net *net, struct net *peer, int reqid)
  * NET_ID_ZERO (-1) for it.
  */
 #define NET_ID_ZERO -1
-static int net_eq_idr(int id, void *net, void *peer)
+static int net_eq_idr(unsigned long id, void *net, void *peer)
 {
 	if (net_eq(net, peer))
 		return id ? : NET_ID_ZERO;
@@ -189,6 +190,8 @@ static int __peernet2id_alloc(struct net *net, struct net *peer, bool *alloc)
 {
 	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
 	bool alloc_it = *alloc;
+	unsigned long index;
+	int ret;
 
 	*alloc = false;
 
@@ -199,9 +202,9 @@ static int __peernet2id_alloc(struct net *net, struct net *peer, bool *alloc)
 		return id;
 
 	if (alloc_it) {
-		id = alloc_netid(net, peer, -1);
+		ret = alloc_netid(net, peer, -1, &index);
 		*alloc = true;
-		return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
+		return ret == 0 ? index : NETNSA_NSID_NOT_ASSIGNED;
 	}
 
 	return NETNSA_NSID_NOT_ASSIGNED;
@@ -616,6 +619,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct nlattr *nla;
 	struct net *peer;
 	int nsid, err;
+	unsigned long index;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
 			  rtnl_net_policy, extack);
@@ -653,11 +657,10 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto out;
 	}
 
-	err = alloc_netid(net, peer, nsid);
+	err = alloc_netid(net, peer, nsid, &index);
 	spin_unlock_bh(&net->nsid_lock);
-	if (err >= 0) {
-		rtnl_net_notifyid(net, RTM_NEWNSID, err);
-		err = 0;
+	if (err == 0) {
+		rtnl_net_notifyid(net, RTM_NEWNSID, index);
 	} else if (err == -ENOSPC && nsid >= 0) {
 		err = -EEXIST;
 		NL_SET_BAD_ATTR(extack, tb[NETNSA_NSID]);
@@ -760,7 +763,7 @@ struct rtnl_net_dump_cb {
 	int s_idx;
 };
 
-static int rtnl_net_dumpid_one(int id, void *peer, void *data)
+static int rtnl_net_dumpid_one(unsigned long id, void *peer, void *data)
 {
 	struct rtnl_net_dump_cb *net_cb = (struct rtnl_net_dump_cb *)data;
 	int ret;
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index a354f19..e96ffe5 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -266,6 +266,7 @@ static int ieee80211_add_nan_func(struct wiphy *wiphy,
 				  struct cfg80211_nan_func *nan_func)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_WDEV_TO_SUB_IF(wdev);
+	unsigned long idr_index;
 	int ret;
 
 	if (sdata->vif.type != NL80211_IFTYPE_NAN)
@@ -276,15 +277,14 @@ static int ieee80211_add_nan_func(struct wiphy *wiphy,
 
 	spin_lock_bh(&sdata->u.nan.func_lock);
 
-	ret = idr_alloc(&sdata->u.nan.function_inst_ids,
-			nan_func, 1, sdata->local->hw.max_nan_de_entries + 1,
-			GFP_ATOMIC);
+	ret = idr_alloc(&sdata->u.nan.function_inst_ids, nan_func, &idr_index,
+			1, sdata->local->hw.max_nan_de_entries + 1, GFP_ATOMIC);
 	spin_unlock_bh(&sdata->u.nan.func_lock);
 
-	if (ret < 0)
+	if (ret)
 		return ret;
 
-	nan_func->instance_id = ret;
+	nan_func->instance_id = idr_index;
 
 	WARN_ON(nan_func->instance_id == 0);
 
@@ -304,7 +304,7 @@ static int ieee80211_add_nan_func(struct wiphy *wiphy,
 				  u64 cookie)
 {
 	struct cfg80211_nan_func *func;
-	int id;
+	unsigned long id;
 
 	lockdep_assert_held(&sdata->u.nan.func_lock);
 
@@ -3266,23 +3266,24 @@ int ieee80211_attach_ack_skb(struct ieee80211_local *local, struct sk_buff *skb,
 {
 	unsigned long spin_flags;
 	struct sk_buff *ack_skb;
-	int id;
+	unsigned long idr_index;
+	int ret;
 
 	ack_skb = skb_copy(skb, gfp);
 	if (!ack_skb)
 		return -ENOMEM;
 
 	spin_lock_irqsave(&local->ack_status_lock, spin_flags);
-	id = idr_alloc(&local->ack_status_frames, ack_skb,
-		       1, 0x10000, GFP_ATOMIC);
+	ret = idr_alloc(&local->ack_status_frames, ack_skb, &idr_index,
+			1, 0x10000, GFP_ATOMIC);
 	spin_unlock_irqrestore(&local->ack_status_lock, spin_flags);
 
-	if (id < 0) {
+	if (ret) {
 		kfree_skb(ack_skb);
 		return -ENOMEM;
 	}
 
-	IEEE80211_SKB_CB(skb)->ack_frame_id = id;
+	IEEE80211_SKB_CB(skb)->ack_frame_id = idr_index;
 
 	*cookie = ieee80211_mgmt_tx_cookie(local);
 	IEEE80211_SKB_CB(ack_skb)->ack.cookie = *cookie;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 9228ac7..517421c 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -797,11 +797,12 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 	unsigned long flags;
 	struct sk_buff *skb, *tmp;
 	u32 hw_reconf_flags = 0;
-	int i, flushed;
+	int flushed;
 	struct ps_data *ps;
 	struct cfg80211_chan_def chandef;
 	bool cancel_scan;
 	struct cfg80211_nan_func *func;
+	unsigned long i;
 
 	clear_bit(SDATA_STATE_RUNNING, &sdata->state);
 
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 8aa1f5b..4195df2 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1209,7 +1209,7 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 }
 EXPORT_SYMBOL(ieee80211_unregister_hw);
 
-static int ieee80211_free_ack_frame(int id, void *p, void *data)
+static int ieee80211_free_ack_frame(unsigned long id, void *p, void *data)
 {
 	WARN_ONCE(1, "Have pending ack frames!\n");
 	kfree_skb(p);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 8858f4f..7aa02b6 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2373,6 +2373,7 @@ static struct sk_buff *ieee80211_build_hdr(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_chanctx_conf *chanctx_conf;
 	struct ieee80211_sub_if_data *ap_sdata;
 	enum nl80211_band band;
+	unsigned long idr_index;
 	int ret;
 
 	if (IS_ERR(sta))
@@ -2623,11 +2624,11 @@ static struct sk_buff *ieee80211_build_hdr(struct ieee80211_sub_if_data *sdata,
 
 			spin_lock_irqsave(&local->ack_status_lock, flags);
 			id = idr_alloc(&local->ack_status_frames, ack_skb,
-				       1, 0x10000, GFP_ATOMIC);
+				       &idr_index, 1, 0x10000, GFP_ATOMIC);
 			spin_unlock_irqrestore(&local->ack_status_lock, flags);
 
-			if (id >= 0) {
-				info_id = id;
+			if (id == 0) {
+				info_id = idr_index;
 				info_flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
 			} else {
 				kfree_skb(ack_skb);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 259698d..4af5d5e 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1755,7 +1755,8 @@ static void ieee80211_reconfig_stations(struct ieee80211_sub_if_data *sdata)
 static int ieee80211_reconfig_nan(struct ieee80211_sub_if_data *sdata)
 {
 	struct cfg80211_nan_func *func, **funcs;
-	int res, id, i = 0;
+	int res, i = 0;
+	unsigned long id;
 
 	res = drv_start_nan(sdata->local, sdata,
 			    &sdata->u.nan.conf);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 10f8b4c..76f0bc4 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -97,7 +97,7 @@ static const struct genl_family *genl_family_find_byid(unsigned int id)
 static const struct genl_family *genl_family_find_byname(char *name)
 {
 	const struct genl_family *family;
-	unsigned int id;
+	unsigned long id;
 
 	idr_for_each_entry(&genl_fam_idr, family, id)
 		if (strcmp(family->name, name) == 0)
@@ -322,6 +322,7 @@ int genl_register_family(struct genl_family *family)
 {
 	int err, i;
 	int start = GENL_START_ALLOC, end = GENL_MAX_ID;
+	unsigned long idr_index;
 
 	err = genl_validate_ops(family);
 	if (err)
@@ -360,12 +361,11 @@ int genl_register_family(struct genl_family *family)
 	} else
 		family->attrbuf = NULL;
 
-	family->id = idr_alloc(&genl_fam_idr, family,
-			       start, end + 1, GFP_KERNEL);
-	if (family->id < 0) {
-		err = family->id;
+	err = idr_alloc(&genl_fam_idr, family, &idr_index,
+			start, end + 1, GFP_KERNEL);
+	if (err)
 		goto errout_locked;
-	}
+	family->id = idr_index;
 
 	err = genl_validate_assign_mc_groups(family);
 	if (err)
@@ -775,7 +775,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	struct genl_family *rt;
 	struct net *net = sock_net(skb->sk);
 	int fams_to_skip = cb->args[0];
-	unsigned int id;
+	unsigned long id;
 
 	idr_for_each_entry(&genl_fam_idr, rt, id) {
 		if (!rt->netnsok && !net_eq(net, &init_net))
@@ -961,7 +961,7 @@ static int genl_bind(struct net *net, int group)
 {
 	struct genl_family *f;
 	int err = -ENOENT;
-	unsigned int id;
+	unsigned long id;
 
 	down_read(&cb_lock);
 
@@ -987,7 +987,7 @@ static int genl_bind(struct net *net, int group)
 static void genl_unbind(struct net *net, int group)
 {
 	struct genl_family *f;
-	unsigned int id;
+	unsigned long id;
 
 	down_read(&cb_lock);
 
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index c2f5c13..939ee02 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -498,28 +498,31 @@ static void qrtr_port_remove(struct qrtr_sock *ipc)
 static int qrtr_port_assign(struct qrtr_sock *ipc, int *port)
 {
 	int rc;
+	unsigned long idr_index;
 
 	mutex_lock(&qrtr_port_lock);
 	if (!*port) {
-		rc = idr_alloc(&qrtr_ports, ipc,
+		rc = idr_alloc(&qrtr_ports, ipc, &idr_index,
 			       QRTR_MIN_EPH_SOCKET, QRTR_MAX_EPH_SOCKET + 1,
 			       GFP_ATOMIC);
-		if (rc >= 0)
-			*port = rc;
+		if (rc == 0)
+			*port = idr_index;
 	} else if (*port < QRTR_MIN_EPH_SOCKET && !capable(CAP_NET_ADMIN)) {
 		rc = -EACCES;
 	} else if (*port == QRTR_PORT_CTRL) {
-		rc = idr_alloc(&qrtr_ports, ipc, 0, 1, GFP_ATOMIC);
+		rc = idr_alloc(&qrtr_ports, ipc, NULL, 0, 1,
+			       GFP_ATOMIC);
 	} else {
-		rc = idr_alloc(&qrtr_ports, ipc, *port, *port + 1, GFP_ATOMIC);
-		if (rc >= 0)
-			*port = rc;
+		rc = idr_alloc(&qrtr_ports, ipc, &idr_index, *port,
+			       *port + 1, GFP_ATOMIC);
+		if (rc == 0)
+			*port = idr_index;
 	}
 	mutex_unlock(&qrtr_port_lock);
 
 	if (rc == -ENOSPC)
 		return -EADDRINUSE;
-	else if (rc < 0)
+	else if (rc)
 		return rc;
 
 	sock_hold(&ipc->sk);
@@ -531,7 +534,7 @@ static int qrtr_port_assign(struct qrtr_sock *ipc, int *port)
 static void qrtr_reset_ports(void)
 {
 	struct qrtr_sock *ipc;
-	int id;
+	unsigned long id;
 
 	mutex_lock(&qrtr_port_lock);
 	idr_for_each_entry(&qrtr_ports, ipc, id) {
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index eb21576..8f49e9c 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -106,16 +106,17 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 					  gfp_t gfp)
 {
 	struct rxrpc_net *rxnet = conn->params.local->rxnet;
-	int id;
+	unsigned long id;
+	int ret;
 
 	_enter("");
 
 	idr_preload(gfp);
 	spin_lock(&rxrpc_conn_id_lock);
 
-	id = idr_alloc_cyclic(&rxrpc_client_conn_ids, conn,
-			      1, 0x40000000, GFP_NOWAIT);
-	if (id < 0)
+	ret = idr_alloc_cyclic(&rxrpc_client_conn_ids, conn, &id,
+			       1, 0x40000000, GFP_NOWAIT);
+	if (ret)
 		goto error;
 
 	spin_unlock(&rxrpc_conn_id_lock);
@@ -130,8 +131,8 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 error:
 	spin_unlock(&rxrpc_conn_id_lock);
 	idr_preload_end();
-	_leave(" = %d", id);
-	return id;
+	_leave(" = %d", ret);
+	return ret;
 }
 
 /*
@@ -153,7 +154,7 @@ static void rxrpc_put_client_connection_id(struct rxrpc_connection *conn)
 void rxrpc_destroy_client_conn_ids(void)
 {
 	struct rxrpc_connection *conn;
-	int id;
+	unsigned long id;
 
 	if (!idr_is_empty(&rxrpc_client_conn_ids)) {
 		idr_for_each_entry(&rxrpc_client_conn_ids, conn, id) {
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index dfb9651..c3086c1 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1613,6 +1613,7 @@ int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
 int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 {
 	bool preload = gfpflags_allow_blocking(gfp);
+	unsigned long idr_index;
 	int ret;
 
 	/* If the id is already assigned, keep it. */
@@ -1623,14 +1624,15 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 		idr_preload(gfp);
 	spin_lock_bh(&sctp_assocs_id_lock);
 	/* 0 is not a valid assoc_id, must be >= 1 */
-	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, &idr_index, 1, 0,
+			       GFP_NOWAIT);
 	spin_unlock_bh(&sctp_assocs_id_lock);
 	if (preload)
 		idr_preload_end();
-	if (ret < 0)
+	if (ret)
 		return ret;
 
-	asoc->assoc_id = (sctp_assoc_t)ret;
+	asoc->assoc_id = (sctp_assoc_t)idr_index;
 	return 0;
 }
 
diff --git a/net/tipc/server.c b/net/tipc/server.c
index 3cd6402..9c83545 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -216,6 +216,7 @@ static void tipc_close_conn(struct tipc_conn *con)
 static struct tipc_conn *tipc_alloc_conn(struct tipc_server *s)
 {
 	struct tipc_conn *con;
+	unsigned long idr_index;
 	int ret;
 
 	con = kzalloc(sizeof(struct tipc_conn), GFP_ATOMIC);
@@ -229,13 +230,13 @@ static struct tipc_conn *tipc_alloc_conn(struct tipc_server *s)
 	INIT_WORK(&con->rwork, tipc_recv_work);
 
 	spin_lock_bh(&s->idr_lock);
-	ret = idr_alloc(&s->conn_idr, con, 0, 0, GFP_ATOMIC);
-	if (ret < 0) {
+	ret = idr_alloc(&s->conn_idr, con, &idr_index, 0, 0, GFP_ATOMIC);
+	if (ret) {
 		kfree(con);
 		spin_unlock_bh(&s->idr_lock);
 		return ERR_PTR(-ENOMEM);
 	}
-	con->conid = ret;
+	con->conid = idr_index;
 	s->idr_in_use++;
 	spin_unlock_bh(&s->idr_lock);
 
-- 
1.8.3.1


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
