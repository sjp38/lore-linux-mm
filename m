From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig-5C7GfCeVMHo@public.gmane.org>
Subject: Re: [patch net-next 0/3] net/sched: Improve getting objects by indexes
Date: Wed, 16 Aug 2017 09:49:07 +0200
Message-ID: <144b87a3-bbe4-a194-ed83-e54840d7c7c2@amd.com>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1502849538-14284-1-git-send-email-chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chris Mi <chrism-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org, sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org, markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org, zhi.a.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, jinpu.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org, sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, AlexBin.Xie-5C7GfCeVMHo@public.gmane.org, david1.zhou-5C7GfCeVMHo@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sudarsana.kalluru-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dtwlin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, michel.daenzer-5C7GfCeVMHo@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, tpmdd-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, longman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, pmladek-IBi9RG/b67k@public.gmane.org, dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.orglinu
List-Id: linux-mm.kvack.org

Am 16.08.2017 um 04:12 schrieb Chris Mi:
> Using current TC code, it is very slow to insert a lot of rules.
>
> In order to improve the rules update rate in TC,
> we introduced the following two changes:
>          1) changed cls_flower to use IDR to manage the filters.
>          2) changed all act_xxx modules to use IDR instead of
>             a small hash table
>
> But IDR has a limitation that it uses int. TC handle uses u32.
> To make sure there is no regression, we also changed IDR to use
> unsigned long. All clients of IDR are changed to use new IDR API.

WOW, wait a second. The idr change is touching a lot of drivers and to 
be honest doesn't looks correct at all.

Just look at the first chunk of your modification:
> @@ -998,8 +999,9 @@ int bsg_register_queue(struct request_queue *q, struct device *parent,
>   
>   	mutex_lock(&bsg_mutex);
>   
> -	ret = idr_alloc(&bsg_minor_idr, bcd, 0, BSG_MAX_DEVS, GFP_KERNEL);
> -	if (ret < 0) {
> +	ret = idr_alloc(&bsg_minor_idr, bcd, &idr_index, 0, BSG_MAX_DEVS,
> +			GFP_KERNEL);
> +	if (ret) {
>   		if (ret == -ENOSPC) {
>   			printk(KERN_ERR "bsg: too many bsg devices\n");
>   			ret = -EINVAL;
The condition "if (ret)" will now always be true after the first 
allocation and so we always run into the error handling after that.

I've never read the bsg code before, but that's certainly not correct. 
And that incorrect pattern repeats over and over again in this code.

Apart from that why the heck do you want to allocate more than 1<<31 
handles?

Regards,
Christian.

>
> Chris Mi (3):
>    idr: Use unsigned long instead of int
>    net/sched: Change cls_flower to use IDR
>    net/sched: Change act_api and act_xxx modules to use IDR
>
>   block/bsg.c                                     |   8 +-
>   block/genhd.c                                   |  12 +-
>   drivers/atm/nicstar.c                           |  11 +-
>   drivers/block/drbd/drbd_main.c                  |  31 +--
>   drivers/block/drbd/drbd_nl.c                    |  22 ++-
>   drivers/block/drbd/drbd_proc.c                  |   3 +-
>   drivers/block/drbd/drbd_receiver.c              |  15 +-
>   drivers/block/drbd/drbd_state.c                 |  34 ++--
>   drivers/block/drbd/drbd_worker.c                |   6 +-
>   drivers/block/loop.c                            |  17 +-
>   drivers/block/nbd.c                             |  20 +-
>   drivers/block/zram/zram_drv.c                   |   9 +-
>   drivers/char/tpm/tpm-chip.c                     |  10 +-
>   drivers/char/tpm/tpm.h                          |   2 +-
>   drivers/dca/dca-sysfs.c                         |   9 +-
>   drivers/firewire/core-cdev.c                    |  18 +-
>   drivers/firewire/core-device.c                  |  15 +-
>   drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c     |   8 +-
>   drivers/gpu/drm/amd/amdgpu/amdgpu_ctx.c         |   9 +-
>   drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c         |   6 +-
>   drivers/gpu/drm/amd/amdgpu/amdgpu_kms.c         |   2 +-
>   drivers/gpu/drm/drm_auth.c                      |   9 +-
>   drivers/gpu/drm/drm_connector.c                 |  10 +-
>   drivers/gpu/drm/drm_context.c                   |  20 +-
>   drivers/gpu/drm/drm_dp_aux_dev.c                |  11 +-
>   drivers/gpu/drm/drm_drv.c                       |   6 +-
>   drivers/gpu/drm/drm_gem.c                       |  19 +-
>   drivers/gpu/drm/drm_info.c                      |   2 +-
>   drivers/gpu/drm/drm_mode_object.c               |  11 +-
>   drivers/gpu/drm/drm_syncobj.c                   |  18 +-
>   drivers/gpu/drm/exynos/exynos_drm_ipp.c         |  25 ++-
>   drivers/gpu/drm/i915/gvt/display.c              |   2 +-
>   drivers/gpu/drm/i915/gvt/kvmgt.c                |   2 +-
>   drivers/gpu/drm/i915/gvt/vgpu.c                 |   9 +-
>   drivers/gpu/drm/i915/i915_debugfs.c             |   6 +-
>   drivers/gpu/drm/i915/i915_gem_context.c         |   9 +-
>   drivers/gpu/drm/qxl/qxl_cmd.c                   |   8 +-
>   drivers/gpu/drm/qxl/qxl_release.c               |  14 +-
>   drivers/gpu/drm/sis/sis_mm.c                    |   8 +-
>   drivers/gpu/drm/tegra/drm.c                     |  10 +-
>   drivers/gpu/drm/tilcdc/tilcdc_slave_compat.c    |   3 +-
>   drivers/gpu/drm/vgem/vgem_fence.c               |  12 +-
>   drivers/gpu/drm/via/via_mm.c                    |   8 +-
>   drivers/gpu/drm/virtio/virtgpu_kms.c            |   5 +-
>   drivers/gpu/drm/virtio/virtgpu_vq.c             |   5 +-
>   drivers/gpu/drm/vmwgfx/vmwgfx_resource.c        |   9 +-
>   drivers/i2c/i2c-core-base.c                     |  19 +-
>   drivers/infiniband/core/cm.c                    |   8 +-
>   drivers/infiniband/core/cma.c                   |  12 +-
>   drivers/infiniband/core/rdma_core.c             |   9 +-
>   drivers/infiniband/core/sa_query.c              |  23 +--
>   drivers/infiniband/core/ucm.c                   |   7 +-
>   drivers/infiniband/core/ucma.c                  |  14 +-
>   drivers/infiniband/hw/cxgb3/iwch.c              |   4 +-
>   drivers/infiniband/hw/cxgb3/iwch.h              |   4 +-
>   drivers/infiniband/hw/cxgb4/device.c            |  18 +-
>   drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   4 +-
>   drivers/infiniband/hw/hfi1/init.c               |   9 +-
>   drivers/infiniband/hw/hfi1/vnic_main.c          |   6 +-
>   drivers/infiniband/hw/mlx4/cm.c                 |  13 +-
>   drivers/infiniband/hw/ocrdma/ocrdma_main.c      |   7 +-
>   drivers/infiniband/hw/qib/qib_init.c            |   9 +-
>   drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c |  10 +-
>   drivers/iommu/intel-svm.c                       |   9 +-
>   drivers/md/dm.c                                 |  13 +-
>   drivers/memstick/core/memstick.c                |  10 +-
>   drivers/memstick/core/ms_block.c                |   9 +-
>   drivers/memstick/core/mspro_block.c             |  12 +-
>   drivers/mfd/rtsx_pcr.c                          |   9 +-
>   drivers/misc/c2port/core.c                      |   7 +-
>   drivers/misc/cxl/context.c                      |   8 +-
>   drivers/misc/cxl/main.c                         |  15 +-
>   drivers/misc/mei/main.c                         |   8 +-
>   drivers/misc/mic/scif/scif_api.c                |  11 +-
>   drivers/misc/mic/scif/scif_ports.c              |  18 +-
>   drivers/misc/tifm_core.c                        |   9 +-
>   drivers/mtd/mtdcore.c                           |   9 +-
>   drivers/mtd/mtdcore.h                           |   2 +-
>   drivers/mtd/ubi/block.c                         |   7 +-
>   drivers/net/ppp/ppp_generic.c                   |  27 +--
>   drivers/net/tap.c                               |  10 +-
>   drivers/net/wireless/ath/ath10k/htt.h           |   3 +-
>   drivers/net/wireless/ath/ath10k/htt_tx.c        |  22 ++-
>   drivers/net/wireless/ath/ath10k/mac.c           |   2 +-
>   drivers/net/wireless/marvell/mwifiex/main.c     |  13 +-
>   drivers/net/wireless/marvell/mwifiex/wmm.c      |   2 +-
>   drivers/of/overlay.c                            |  15 +-
>   drivers/of/unittest.c                           |  25 ++-
>   drivers/power/supply/bq2415x_charger.c          |  16 +-
>   drivers/power/supply/bq27xxx_battery_i2c.c      |  15 +-
>   drivers/power/supply/ds2782_battery.c           |   9 +-
>   drivers/powercap/powercap_sys.c                 |   8 +-
>   drivers/pps/pps.c                               |  10 +-
>   drivers/rapidio/rio_cm.c                        |  17 +-
>   drivers/remoteproc/remoteproc_core.c            |   8 +-
>   drivers/rpmsg/virtio_rpmsg_bus.c                |   8 +-
>   drivers/scsi/bfa/bfad_im.c                      |   8 +-
>   drivers/scsi/ch.c                               |   8 +-
>   drivers/scsi/lpfc/lpfc_crtn.h                   |   2 +-
>   drivers/scsi/lpfc/lpfc_init.c                   |  11 +-
>   drivers/scsi/lpfc/lpfc_vport.c                  |   8 +-
>   drivers/scsi/sg.c                               |  10 +-
>   drivers/scsi/st.c                               |   8 +-
>   drivers/staging/greybus/uart.c                  |  22 +--
>   drivers/staging/unisys/visorhba/visorhba_main.c |   7 +-
>   drivers/target/iscsi/iscsi_target.c             |   7 +-
>   drivers/target/iscsi/iscsi_target_login.c       |   9 +-
>   drivers/target/target_core_device.c             |   9 +-
>   drivers/target/target_core_user.c               |  13 +-
>   drivers/tee/tee_shm.c                           |   8 +-
>   drivers/uio/uio.c                               |   9 +-
>   drivers/usb/class/cdc-acm.c                     |  24 +--
>   drivers/usb/core/devices.c                      |   2 +-
>   drivers/usb/core/hcd.c                          |   7 +-
>   drivers/usb/mon/mon_main.c                      |   3 +-
>   drivers/usb/serial/usb-serial.c                 |  11 +-
>   drivers/vfio/vfio.c                             |  15 +-
>   fs/dlm/lock.c                                   |   9 +-
>   fs/dlm/lockspace.c                              |   6 +-
>   fs/dlm/recover.c                                |  10 +-
>   fs/nfs/nfs4client.c                             |   9 +-
>   fs/nfsd/nfs4state.c                             |   8 +-
>   fs/notify/inotify/inotify_fsnotify.c            |   4 +-
>   fs/notify/inotify/inotify_user.c                |   9 +-
>   fs/ocfs2/cluster/tcp.c                          |  10 +-
>   include/linux/idr.h                             |  26 +--
>   include/linux/of.h                              |   4 +-
>   include/linux/radix-tree.h                      |   2 +-
>   include/net/9p/9p.h                             |   2 +-
>   include/net/act_api.h                           |  76 +++-----
>   ipc/msg.c                                       |   2 +-
>   ipc/sem.c                                       |   2 +-
>   ipc/shm.c                                       |   4 +-
>   ipc/util.c                                      |  17 +-
>   kernel/bpf/syscall.c                            |  20 +-
>   kernel/cgroup/cgroup.c                          |  57 +++---
>   kernel/events/core.c                            |  10 +-
>   kernel/workqueue.c                              |  15 +-
>   lib/idr.c                                       |  38 ++--
>   lib/radix-tree.c                                |   5 +-
>   mm/memcontrol.c                                 |  11 +-
>   net/9p/client.c                                 |  17 +-
>   net/9p/util.c                                   |  14 +-
>   net/core/net_namespace.c                        |  23 ++-
>   net/mac80211/cfg.c                              |  23 +--
>   net/mac80211/iface.c                            |   3 +-
>   net/mac80211/main.c                             |   2 +-
>   net/mac80211/tx.c                               |   7 +-
>   net/mac80211/util.c                             |   3 +-
>   net/netlink/genetlink.c                         |  18 +-
>   net/qrtr/qrtr.c                                 |  21 +-
>   net/rxrpc/conn_client.c                         |  15 +-
>   net/sched/act_api.c                             | 249 +++++++++++-------------
>   net/sched/act_bpf.c                             |  17 +-
>   net/sched/act_connmark.c                        |  16 +-
>   net/sched/act_csum.c                            |  16 +-
>   net/sched/act_gact.c                            |  16 +-
>   net/sched/act_ife.c                             |  20 +-
>   net/sched/act_ipt.c                             |  26 ++-
>   net/sched/act_mirred.c                          |  19 +-
>   net/sched/act_nat.c                             |  16 +-
>   net/sched/act_pedit.c                           |  18 +-
>   net/sched/act_police.c                          |  18 +-
>   net/sched/act_sample.c                          |  17 +-
>   net/sched/act_simple.c                          |  20 +-
>   net/sched/act_skbedit.c                         |  18 +-
>   net/sched/act_skbmod.c                          |  18 +-
>   net/sched/act_tunnel_key.c                      |  20 +-
>   net/sched/act_vlan.c                            |  22 +--
>   net/sched/cls_flower.c                          |  55 +++---
>   net/sctp/associola.c                            |   8 +-
>   net/tipc/server.c                               |   7 +-
>   172 files changed, 1256 insertions(+), 1113 deletions(-)
>
