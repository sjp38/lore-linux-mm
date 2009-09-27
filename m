Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 058F46B00A4
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:27:18 -0400 (EDT)
Received: by ewy19 with SMTP id 19so3677752ewy.4
        for <linux-mm@kvack.org>; Sun, 27 Sep 2009 11:42:03 -0700 (PDT)
Date: Sun, 27 Sep 2009 22:42:01 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] const: mark struct vm_struct_operations
Message-ID: <20090927184201.GA12402@x200>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* mark struct vm_area_struct::vm_ops as const
* mark vm_ops in AGP code

But leave TTM code alone, something is fishy there with global vm_ops
being used.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/ia64/ia32/binfmt_elf32.c                |    4 ++--
 arch/powerpc/platforms/cell/spufs/file.c     |   14 +++++++-------
 arch/x86/pci/i386.c                          |    2 +-
 drivers/char/agp/agp.h                       |    2 +-
 drivers/char/agp/alpha-agp.c                 |    2 +-
 drivers/char/mem.c                           |    2 +-
 drivers/char/mspec.c                         |    2 +-
 drivers/gpu/drm/drm_vm.c                     |    8 ++++----
 drivers/gpu/drm/radeon/radeon_ttm.c          |    2 +-
 drivers/gpu/drm/ttm/ttm_bo_vm.c              |    2 +-
 drivers/ieee1394/dma.c                       |    2 +-
 drivers/infiniband/hw/ehca/ehca_uverbs.c     |    2 +-
 drivers/infiniband/hw/ipath/ipath_file_ops.c |    2 +-
 drivers/infiniband/hw/ipath/ipath_mmap.c     |    2 +-
 drivers/media/video/cafe_ccic.c              |    2 +-
 drivers/media/video/et61x251/et61x251_core.c |    2 +-
 drivers/media/video/gspca/gspca.c            |    2 +-
 drivers/media/video/meye.c                   |    2 +-
 drivers/media/video/sn9c102/sn9c102_core.c   |    2 +-
 drivers/media/video/stk-webcam.c             |    2 +-
 drivers/media/video/uvc/uvc_v4l2.c           |    2 +-
 drivers/media/video/videobuf-dma-contig.c    |    2 +-
 drivers/media/video/videobuf-dma-sg.c        |    2 +-
 drivers/media/video/videobuf-vmalloc.c       |    2 +-
 drivers/media/video/vino.c                   |    2 +-
 drivers/media/video/zc0301/zc0301_core.c     |    2 +-
 drivers/media/video/zoran/zoran_driver.c     |    2 +-
 drivers/misc/sgi-gru/grufile.c               |    2 +-
 drivers/misc/sgi-gru/grutables.h             |    2 +-
 drivers/scsi/sg.c                            |    2 +-
 drivers/uio/uio.c                            |    2 +-
 drivers/usb/mon/mon_bin.c                    |    2 +-
 drivers/video/fb_defio.c                     |    2 +-
 drivers/video/omap/dispc.c                   |    2 +-
 fs/btrfs/file.c                              |    2 +-
 fs/ext4/file.c                               |    2 +-
 fs/fuse/file.c                               |    2 +-
 fs/gfs2/file.c                               |    2 +-
 fs/ncpfs/mmap.c                              |    2 +-
 fs/nfs/file.c                                |    4 ++--
 fs/nilfs2/file.c                             |    2 +-
 fs/ocfs2/mmap.c                              |    2 +-
 fs/sysfs/bin.c                               |    4 ++--
 fs/ubifs/file.c                              |    2 +-
 fs/xfs/linux-2.6/xfs_file.c                  |    4 ++--
 include/linux/agp_backend.h                  |    2 +-
 include/linux/hugetlb.h                      |    2 +-
 include/linux/mm_types.h                     |    2 +-
 include/linux/ramfs.h                        |    2 +-
 ipc/shm.c                                    |    4 ++--
 kernel/perf_event.c                          |    2 +-
 kernel/relay.c                               |    2 +-
 mm/filemap.c                                 |    2 +-
 mm/filemap_xip.c                             |    2 +-
 mm/hugetlb.c                                 |    2 +-
 mm/mmap.c                                    |    2 +-
 mm/nommu.c                                   |    2 +-
 mm/shmem.c                                   |    4 ++--
 net/packet/af_packet.c                       |    2 +-
 sound/core/pcm_native.c                      |    8 ++++----
 sound/usb/usx2y/us122l.c                     |    2 +-
 sound/usb/usx2y/usX2Yhwdep.c                 |    2 +-
 sound/usb/usx2y/usx2yhwdeppcm.c              |    2 +-
 virt/kvm/kvm_main.c                          |    4 ++--
 64 files changed, 83 insertions(+), 83 deletions(-)

--- a/arch/ia64/ia32/binfmt_elf32.c
+++ b/arch/ia64/ia32/binfmt_elf32.c
@@ -69,11 +69,11 @@ ia32_install_gate_page (struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 
 
-static struct vm_operations_struct ia32_shared_page_vm_ops = {
+static const struct vm_operations_struct ia32_shared_page_vm_ops = {
 	.fault = ia32_install_shared_page
 };
 
-static struct vm_operations_struct ia32_gate_page_vm_ops = {
+static const struct vm_operations_struct ia32_gate_page_vm_ops = {
 	.fault = ia32_install_gate_page
 };
 
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -309,7 +309,7 @@ static int spufs_mem_mmap_access(struct vm_area_struct *vma,
 	return len;
 }
 
-static struct vm_operations_struct spufs_mem_mmap_vmops = {
+static const struct vm_operations_struct spufs_mem_mmap_vmops = {
 	.fault = spufs_mem_mmap_fault,
 	.access = spufs_mem_mmap_access,
 };
@@ -436,7 +436,7 @@ static int spufs_cntl_mmap_fault(struct vm_area_struct *vma,
 	return spufs_ps_fault(vma, vmf, 0x4000, SPUFS_CNTL_MAP_SIZE);
 }
 
-static struct vm_operations_struct spufs_cntl_mmap_vmops = {
+static const struct vm_operations_struct spufs_cntl_mmap_vmops = {
 	.fault = spufs_cntl_mmap_fault,
 };
 
@@ -1143,7 +1143,7 @@ spufs_signal1_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 #endif
 }
 
-static struct vm_operations_struct spufs_signal1_mmap_vmops = {
+static const struct vm_operations_struct spufs_signal1_mmap_vmops = {
 	.fault = spufs_signal1_mmap_fault,
 };
 
@@ -1279,7 +1279,7 @@ spufs_signal2_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 #endif
 }
 
-static struct vm_operations_struct spufs_signal2_mmap_vmops = {
+static const struct vm_operations_struct spufs_signal2_mmap_vmops = {
 	.fault = spufs_signal2_mmap_fault,
 };
 
@@ -1397,7 +1397,7 @@ spufs_mss_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return spufs_ps_fault(vma, vmf, 0x0000, SPUFS_MSS_MAP_SIZE);
 }
 
-static struct vm_operations_struct spufs_mss_mmap_vmops = {
+static const struct vm_operations_struct spufs_mss_mmap_vmops = {
 	.fault = spufs_mss_mmap_fault,
 };
 
@@ -1458,7 +1458,7 @@ spufs_psmap_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return spufs_ps_fault(vma, vmf, 0x0000, SPUFS_PS_MAP_SIZE);
 }
 
-static struct vm_operations_struct spufs_psmap_mmap_vmops = {
+static const struct vm_operations_struct spufs_psmap_mmap_vmops = {
 	.fault = spufs_psmap_mmap_fault,
 };
 
@@ -1517,7 +1517,7 @@ spufs_mfc_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return spufs_ps_fault(vma, vmf, 0x3000, SPUFS_MFC_MAP_SIZE);
 }
 
-static struct vm_operations_struct spufs_mfc_mmap_vmops = {
+static const struct vm_operations_struct spufs_mfc_mmap_vmops = {
 	.fault = spufs_mfc_mmap_fault,
 };
 
--- a/arch/x86/pci/i386.c
+++ b/arch/x86/pci/i386.c
@@ -266,7 +266,7 @@ void pcibios_set_master(struct pci_dev *dev)
 	pci_write_config_byte(dev, PCI_LATENCY_TIMER, lat);
 }
 
-static struct vm_operations_struct pci_mmap_ops = {
+static const struct vm_operations_struct pci_mmap_ops = {
 	.access = generic_access_phys,
 };
 
--- a/drivers/char/agp/agp.h
+++ b/drivers/char/agp/agp.h
@@ -131,7 +131,7 @@ struct agp_bridge_driver {
 struct agp_bridge_data {
 	const struct agp_version *version;
 	const struct agp_bridge_driver *driver;
-	struct vm_operations_struct *vm_ops;
+	const struct vm_operations_struct *vm_ops;
 	void *previous_size;
 	void *current_size;
 	void *dev_private_data;
--- a/drivers/char/agp/alpha-agp.c
+++ b/drivers/char/agp/alpha-agp.c
@@ -40,7 +40,7 @@ static struct aper_size_info_fixed alpha_core_agp_sizes[] =
 	{ 0, 0, 0 }, /* filled in by alpha_core_agp_setup */
 };
 
-struct vm_operations_struct alpha_core_agp_vm_ops = {
+static const struct vm_operations_struct alpha_core_agp_vm_ops = {
 	.fault = alpha_core_agp_vm_fault,
 };
 
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -301,7 +301,7 @@ static inline int private_mapping_ok(struct vm_area_struct *vma)
 }
 #endif
 
-static struct vm_operations_struct mmap_mem_ops = {
+static const struct vm_operations_struct mmap_mem_ops = {
 #ifdef CONFIG_HAVE_IOREMAP_PROT
 	.access = generic_access_phys
 #endif
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -239,7 +239,7 @@ mspec_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return VM_FAULT_NOPAGE;
 }
 
-static struct vm_operations_struct mspec_vm_ops = {
+static const struct vm_operations_struct mspec_vm_ops = {
 	.open = mspec_open,
 	.close = mspec_close,
 	.fault = mspec_fault,
--- a/drivers/gpu/drm/drm_vm.c
+++ b/drivers/gpu/drm/drm_vm.c
@@ -369,28 +369,28 @@ static int drm_vm_sg_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 
 /** AGP virtual memory operations */
-static struct vm_operations_struct drm_vm_ops = {
+static const struct vm_operations_struct drm_vm_ops = {
 	.fault = drm_vm_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_close,
 };
 
 /** Shared virtual memory operations */
-static struct vm_operations_struct drm_vm_shm_ops = {
+static const struct vm_operations_struct drm_vm_shm_ops = {
 	.fault = drm_vm_shm_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_shm_close,
 };
 
 /** DMA virtual memory operations */
-static struct vm_operations_struct drm_vm_dma_ops = {
+static const struct vm_operations_struct drm_vm_dma_ops = {
 	.fault = drm_vm_dma_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_close,
 };
 
 /** Scatter-gather virtual memory operations */
-static struct vm_operations_struct drm_vm_sg_ops = {
+static const struct vm_operations_struct drm_vm_sg_ops = {
 	.fault = drm_vm_sg_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_close,
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -530,7 +530,7 @@ void radeon_ttm_fini(struct radeon_device *rdev)
 }
 
 static struct vm_operations_struct radeon_ttm_vm_ops;
-static struct vm_operations_struct *ttm_vm_ops = NULL;
+static const struct vm_operations_struct *ttm_vm_ops = NULL;
 
 static int radeon_ttm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -228,7 +228,7 @@ static void ttm_bo_vm_close(struct vm_area_struct *vma)
 	vma->vm_private_data = NULL;
 }
 
-static struct vm_operations_struct ttm_bo_vm_ops = {
+static const struct vm_operations_struct ttm_bo_vm_ops = {
 	.fault = ttm_bo_vm_fault,
 	.open = ttm_bo_vm_open,
 	.close = ttm_bo_vm_close
--- a/drivers/ieee1394/dma.c
+++ b/drivers/ieee1394/dma.c
@@ -247,7 +247,7 @@ static int dma_region_pagefault(struct vm_area_struct *vma,
 	return 0;
 }
 
-static struct vm_operations_struct dma_region_vm_ops = {
+static const struct vm_operations_struct dma_region_vm_ops = {
 	.fault = dma_region_pagefault,
 };
 
--- a/drivers/infiniband/hw/ehca/ehca_uverbs.c
+++ b/drivers/infiniband/hw/ehca/ehca_uverbs.c
@@ -95,7 +95,7 @@ static void ehca_mm_close(struct vm_area_struct *vma)
 		     vma->vm_start, vma->vm_end, *count);
 }
 
-static struct vm_operations_struct vm_ops = {
+static const struct vm_operations_struct vm_ops = {
 	.open =	ehca_mm_open,
 	.close = ehca_mm_close,
 };
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -1151,7 +1151,7 @@ static int ipath_file_vma_fault(struct vm_area_struct *vma,
 	return 0;
 }
 
-static struct vm_operations_struct ipath_file_vm_ops = {
+static const struct vm_operations_struct ipath_file_vm_ops = {
 	.fault = ipath_file_vma_fault,
 };
 
--- a/drivers/infiniband/hw/ipath/ipath_mmap.c
+++ b/drivers/infiniband/hw/ipath/ipath_mmap.c
@@ -74,7 +74,7 @@ static void ipath_vma_close(struct vm_area_struct *vma)
 	kref_put(&ip->ref, ipath_release_mmap_info);
 }
 
-static struct vm_operations_struct ipath_vm_ops = {
+static const struct vm_operations_struct ipath_vm_ops = {
 	.open =     ipath_vma_open,
 	.close =    ipath_vma_close,
 };
--- a/drivers/media/video/cafe_ccic.c
+++ b/drivers/media/video/cafe_ccic.c
@@ -1325,7 +1325,7 @@ static void cafe_v4l_vm_close(struct vm_area_struct *vma)
 	mutex_unlock(&sbuf->cam->s_mutex);
 }
 
-static struct vm_operations_struct cafe_v4l_vm_ops = {
+static const struct vm_operations_struct cafe_v4l_vm_ops = {
 	.open = cafe_v4l_vm_open,
 	.close = cafe_v4l_vm_close
 };
--- a/drivers/media/video/et61x251/et61x251_core.c
+++ b/drivers/media/video/et61x251/et61x251_core.c
@@ -1496,7 +1496,7 @@ static void et61x251_vm_close(struct vm_area_struct* vma)
 }
 
 
-static struct vm_operations_struct et61x251_vm_ops = {
+static const struct vm_operations_struct et61x251_vm_ops = {
 	.open = et61x251_vm_open,
 	.close = et61x251_vm_close,
 };
--- a/drivers/media/video/gspca/gspca.c
+++ b/drivers/media/video/gspca/gspca.c
@@ -99,7 +99,7 @@ static void gspca_vm_close(struct vm_area_struct *vma)
 		frame->v4l2_buf.flags &= ~V4L2_BUF_FLAG_MAPPED;
 }
 
-static struct vm_operations_struct gspca_vm_ops = {
+static const struct vm_operations_struct gspca_vm_ops = {
 	.open		= gspca_vm_open,
 	.close		= gspca_vm_close,
 };
--- a/drivers/media/video/meye.c
+++ b/drivers/media/video/meye.c
@@ -1589,7 +1589,7 @@ static void meye_vm_close(struct vm_area_struct *vma)
 	meye.vma_use_count[idx]--;
 }
 
-static struct vm_operations_struct meye_vm_ops = {
+static const struct vm_operations_struct meye_vm_ops = {
 	.open		= meye_vm_open,
 	.close		= meye_vm_close,
 };
--- a/drivers/media/video/sn9c102/sn9c102_core.c
+++ b/drivers/media/video/sn9c102/sn9c102_core.c
@@ -2077,7 +2077,7 @@ static void sn9c102_vm_close(struct vm_area_struct* vma)
 }
 
 
-static struct vm_operations_struct sn9c102_vm_ops = {
+static const struct vm_operations_struct sn9c102_vm_ops = {
 	.open = sn9c102_vm_open,
 	.close = sn9c102_vm_close,
 };
--- a/drivers/media/video/stk-webcam.c
+++ b/drivers/media/video/stk-webcam.c
@@ -790,7 +790,7 @@ static void stk_v4l_vm_close(struct vm_area_struct *vma)
 	if (sbuf->mapcount == 0)
 		sbuf->v4lbuf.flags &= ~V4L2_BUF_FLAG_MAPPED;
 }
-static struct vm_operations_struct stk_v4l_vm_ops = {
+static const struct vm_operations_struct stk_v4l_vm_ops = {
 	.open = stk_v4l_vm_open,
 	.close = stk_v4l_vm_close
 };
--- a/drivers/media/video/uvc/uvc_v4l2.c
+++ b/drivers/media/video/uvc/uvc_v4l2.c
@@ -1069,7 +1069,7 @@ static void uvc_vm_close(struct vm_area_struct *vma)
 	buffer->vma_use_count--;
 }
 
-static struct vm_operations_struct uvc_vm_ops = {
+static const struct vm_operations_struct uvc_vm_ops = {
 	.open		= uvc_vm_open,
 	.close		= uvc_vm_close,
 };
--- a/drivers/media/video/videobuf-dma-contig.c
+++ b/drivers/media/video/videobuf-dma-contig.c
@@ -105,7 +105,7 @@ static void videobuf_vm_close(struct vm_area_struct *vma)
 	}
 }
 
-static struct vm_operations_struct videobuf_vm_ops = {
+static const struct vm_operations_struct videobuf_vm_ops = {
 	.open     = videobuf_vm_open,
 	.close    = videobuf_vm_close,
 };
--- a/drivers/media/video/videobuf-dma-sg.c
+++ b/drivers/media/video/videobuf-dma-sg.c
@@ -394,7 +394,7 @@ videobuf_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct videobuf_vm_ops =
+static const struct vm_operations_struct videobuf_vm_ops =
 {
 	.open     = videobuf_vm_open,
 	.close    = videobuf_vm_close,
--- a/drivers/media/video/videobuf-vmalloc.c
+++ b/drivers/media/video/videobuf-vmalloc.c
@@ -116,7 +116,7 @@ static void videobuf_vm_close(struct vm_area_struct *vma)
 	return;
 }
 
-static struct vm_operations_struct videobuf_vm_ops =
+static const struct vm_operations_struct videobuf_vm_ops =
 {
 	.open     = videobuf_vm_open,
 	.close    = videobuf_vm_close,
--- a/drivers/media/video/vino.c
+++ b/drivers/media/video/vino.c
@@ -3857,7 +3857,7 @@ static void vino_vm_close(struct vm_area_struct *vma)
 	dprintk("vino_vm_close(): count = %d\n", fb->map_count);
 }
 
-static struct vm_operations_struct vino_vm_ops = {
+static const struct vm_operations_struct vino_vm_ops = {
 	.open	= vino_vm_open,
 	.close	= vino_vm_close,
 };
--- a/drivers/media/video/zc0301/zc0301_core.c
+++ b/drivers/media/video/zc0301/zc0301_core.c
@@ -935,7 +935,7 @@ static void zc0301_vm_close(struct vm_area_struct* vma)
 }
 
 
-static struct vm_operations_struct zc0301_vm_ops = {
+static const struct vm_operations_struct zc0301_vm_ops = {
 	.open = zc0301_vm_open,
 	.close = zc0301_vm_close,
 };
--- a/drivers/media/video/zoran/zoran_driver.c
+++ b/drivers/media/video/zoran/zoran_driver.c
@@ -3172,7 +3172,7 @@ zoran_vm_close (struct vm_area_struct *vma)
 	mutex_unlock(&zr->resource_lock);
 }
 
-static struct vm_operations_struct zoran_vm_ops = {
+static const struct vm_operations_struct zoran_vm_ops = {
 	.open = zoran_vm_open,
 	.close = zoran_vm_close,
 };
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -438,7 +438,7 @@ static struct miscdevice gru_miscdev = {
 	.fops		= &gru_fops,
 };
 
-struct vm_operations_struct gru_vm_ops = {
+const struct vm_operations_struct gru_vm_ops = {
 	.close		= gru_vma_close,
 	.fault		= gru_fault,
 };
--- a/drivers/misc/sgi-gru/grutables.h
+++ b/drivers/misc/sgi-gru/grutables.h
@@ -624,7 +624,7 @@ static inline int is_kernel_context(struct gru_thread_state *gts)
  */
 struct gru_unload_context_req;
 
-extern struct vm_operations_struct gru_vm_ops;
+extern const struct vm_operations_struct gru_vm_ops;
 extern struct device *grudev;
 
 extern struct gru_vma_data *gru_alloc_vma_data(struct vm_area_struct *vma,
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -1185,7 +1185,7 @@ sg_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return VM_FAULT_SIGBUS;
 }
 
-static struct vm_operations_struct sg_mmap_vm_ops = {
+static const struct vm_operations_struct sg_mmap_vm_ops = {
 	.fault = sg_vma_fault,
 };
 
--- a/drivers/uio/uio.c
+++ b/drivers/uio/uio.c
@@ -658,7 +658,7 @@ static int uio_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct uio_vm_ops = {
+static const struct vm_operations_struct uio_vm_ops = {
 	.open = uio_vma_open,
 	.close = uio_vma_close,
 	.fault = uio_vma_fault,
--- a/drivers/usb/mon/mon_bin.c
+++ b/drivers/usb/mon/mon_bin.c
@@ -1174,7 +1174,7 @@ static int mon_bin_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct mon_bin_vm_ops = {
+static const struct vm_operations_struct mon_bin_vm_ops = {
 	.open =     mon_bin_vma_open,
 	.close =    mon_bin_vma_close,
 	.fault =    mon_bin_vma_fault,
--- a/drivers/video/fb_defio.c
+++ b/drivers/video/fb_defio.c
@@ -125,7 +125,7 @@ page_already_added:
 	return 0;
 }
 
-static struct vm_operations_struct fb_deferred_io_vm_ops = {
+static const struct vm_operations_struct fb_deferred_io_vm_ops = {
 	.fault		= fb_deferred_io_fault,
 	.page_mkwrite	= fb_deferred_io_mkwrite,
 };
--- a/drivers/video/omap/dispc.c
+++ b/drivers/video/omap/dispc.c
@@ -1035,7 +1035,7 @@ static void mmap_user_close(struct vm_area_struct *vma)
 	atomic_dec(&dispc.map_count[plane]);
 }
 
-static struct vm_operations_struct mmap_user_ops = {
+static const struct vm_operations_struct mmap_user_ops = {
 	.open = mmap_user_open,
 	.close = mmap_user_close,
 };
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1184,7 +1184,7 @@ out:
 	return ret > 0 ? EIO : ret;
 }
 
-static struct vm_operations_struct btrfs_file_vm_ops = {
+static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= btrfs_page_mkwrite,
 };
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -81,7 +81,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 	return generic_file_aio_write(iocb, iov, nr_segs, pos);
 }
 
-static struct vm_operations_struct ext4_file_vm_ops = {
+static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
 };
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1313,7 +1313,7 @@ static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct fuse_file_vm_ops = {
+static const struct vm_operations_struct fuse_file_vm_ops = {
 	.close		= fuse_vma_close,
 	.fault		= filemap_fault,
 	.page_mkwrite	= fuse_page_mkwrite,
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -418,7 +418,7 @@ out:
 	return ret;
 }
 
-static struct vm_operations_struct gfs2_vm_ops = {
+static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = gfs2_page_mkwrite,
 };
--- a/fs/ncpfs/mmap.c
+++ b/fs/ncpfs/mmap.c
@@ -95,7 +95,7 @@ static int ncp_file_mmap_fault(struct vm_area_struct *area,
 	return VM_FAULT_MAJOR;
 }
 
-static struct vm_operations_struct ncp_file_mmap =
+static const struct vm_operations_struct ncp_file_mmap =
 {
 	.fault = ncp_file_mmap_fault,
 };
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -59,7 +59,7 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl);
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl);
 static int nfs_setlease(struct file *file, long arg, struct file_lock **fl);
 
-static struct vm_operations_struct nfs_file_vm_ops;
+static const struct vm_operations_struct nfs_file_vm_ops;
 
 const struct file_operations nfs_file_operations = {
 	.llseek		= nfs_file_llseek,
@@ -572,7 +572,7 @@ out_unlock:
 	return VM_FAULT_SIGBUS;
 }
 
-static struct vm_operations_struct nfs_file_vm_ops = {
+static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
 	.page_mkwrite = nfs_vm_page_mkwrite,
 };
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -117,7 +117,7 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-struct vm_operations_struct nilfs_file_vm_ops = {
+static const struct vm_operations_struct nilfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= nilfs_page_mkwrite,
 };
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -202,7 +202,7 @@ out:
 	return ret;
 }
 
-static struct vm_operations_struct ocfs2_file_vm_ops = {
+static const struct vm_operations_struct ocfs2_file_vm_ops = {
 	.fault		= ocfs2_fault,
 	.page_mkwrite	= ocfs2_page_mkwrite,
 };
--- a/fs/sysfs/bin.c
+++ b/fs/sysfs/bin.c
@@ -40,7 +40,7 @@ struct bin_buffer {
 	struct mutex			mutex;
 	void				*buffer;
 	int				mmapped;
-	struct vm_operations_struct 	*vm_ops;
+	const struct vm_operations_struct *vm_ops;
 	struct file			*file;
 	struct hlist_node		list;
 };
@@ -331,7 +331,7 @@ static int bin_migrate(struct vm_area_struct *vma, const nodemask_t *from,
 }
 #endif
 
-static struct vm_operations_struct bin_vm_ops = {
+static const struct vm_operations_struct bin_vm_ops = {
 	.open		= bin_vma_open,
 	.close		= bin_vma_close,
 	.fault		= bin_fault,
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1534,7 +1534,7 @@ out_unlock:
 	return err;
 }
 
-static struct vm_operations_struct ubifs_file_vm_ops = {
+static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.fault        = filemap_fault,
 	.page_mkwrite = ubifs_vm_page_mkwrite,
 };
--- a/fs/xfs/linux-2.6/xfs_file.c
+++ b/fs/xfs/linux-2.6/xfs_file.c
@@ -42,7 +42,7 @@
 
 #include <linux/dcache.h>
 
-static struct vm_operations_struct xfs_file_vm_ops;
+static const struct vm_operations_struct xfs_file_vm_ops;
 
 STATIC ssize_t
 xfs_file_aio_read(
@@ -280,7 +280,7 @@ const struct file_operations xfs_dir_file_operations = {
 	.fsync		= xfs_file_fsync,
 };
 
-static struct vm_operations_struct xfs_file_vm_ops = {
+static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
 };
--- a/include/linux/agp_backend.h
+++ b/include/linux/agp_backend.h
@@ -53,7 +53,7 @@ struct agp_kern_info {
 	int current_memory;
 	bool cant_use_aperture;
 	unsigned long page_mask;
-	struct vm_operations_struct *vm_ops;
+	const struct vm_operations_struct *vm_ops;
 };
 
 /*
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -163,7 +163,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 }
 
 extern const struct file_operations hugetlbfs_file_operations;
-extern struct vm_operations_struct hugetlb_vm_ops;
+extern const struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t size, int acct,
 				struct user_struct **user, int creat_flags);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -171,7 +171,7 @@ struct vm_area_struct {
 	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
 
 	/* Function pointers to deal with this struct. */
-	struct vm_operations_struct * vm_ops;
+	const struct vm_operations_struct *vm_ops;
 
 	/* Information about our backing store: */
 	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
--- a/include/linux/ramfs.h
+++ b/include/linux/ramfs.h
@@ -17,7 +17,7 @@ extern int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma);
 #endif
 
 extern const struct file_operations ramfs_file_operations;
-extern struct vm_operations_struct generic_file_vm_ops;
+extern const struct vm_operations_struct generic_file_vm_ops;
 extern int __init init_rootfs(void);
 
 #endif
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -55,7 +55,7 @@ struct shm_file_data {
 #define shm_file_data(file) (*((struct shm_file_data **)&(file)->private_data))
 
 static const struct file_operations shm_file_operations;
-static struct vm_operations_struct shm_vm_ops;
+static const struct vm_operations_struct shm_vm_ops;
 
 #define shm_ids(ns)	((ns)->ids[IPC_SHM_IDS])
 
@@ -312,7 +312,7 @@ static const struct file_operations shm_file_operations = {
 	.get_unmapped_area	= shm_get_unmapped_area,
 };
 
-static struct vm_operations_struct shm_vm_ops = {
+static const struct vm_operations_struct shm_vm_ops = {
 	.open	= shm_open,	/* callback for a new vm-area open */
 	.close	= shm_close,	/* callback for when the vm-area is released */
 	.fault	= shm_fault,
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -2253,7 +2253,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 	}
 }
 
-static struct vm_operations_struct perf_mmap_vmops = {
+static const struct vm_operations_struct perf_mmap_vmops = {
 	.open		= perf_mmap_open,
 	.close		= perf_mmap_close,
 	.fault		= perf_mmap_fault,
--- a/kernel/relay.c
+++ b/kernel/relay.c
@@ -60,7 +60,7 @@ static int relay_buf_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 /*
  * vm_ops for relay file mappings.
  */
-static struct vm_operations_struct relay_file_mmap_ops = {
+static const struct vm_operations_struct relay_file_mmap_ops = {
 	.fault = relay_buf_fault,
 	.close = relay_file_mmap_close,
 };
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1611,7 +1611,7 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
-struct vm_operations_struct generic_file_vm_ops = {
+const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
 };
 
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -296,7 +296,7 @@ out:
 	}
 }
 
-static struct vm_operations_struct xip_file_vm_ops = {
+static const struct vm_operations_struct xip_file_vm_ops = {
 	.fault	= xip_file_fault,
 };
 
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1721,7 +1721,7 @@ static int hugetlb_vm_op_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-struct vm_operations_struct hugetlb_vm_ops = {
+const struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
 	.open = hugetlb_vm_op_open,
 	.close = hugetlb_vm_op_close,
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2282,7 +2282,7 @@ static void special_mapping_close(struct vm_area_struct *vma)
 {
 }
 
-static struct vm_operations_struct special_mapping_vmops = {
+static const struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
 	.fault = special_mapping_fault,
 };
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -79,7 +79,7 @@ static struct kmem_cache *vm_region_jar;
 struct rb_root nommu_region_tree = RB_ROOT;
 DECLARE_RWSEM(nommu_region_sem);
 
-struct vm_operations_struct generic_file_vm_ops = {
+const struct vm_operations_struct generic_file_vm_ops = {
 };
 
 /*
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -218,7 +218,7 @@ static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
 static const struct inode_operations shmem_special_inode_operations;
-static struct vm_operations_struct shmem_vm_ops;
+static const struct vm_operations_struct shmem_vm_ops;
 
 static struct backing_dev_info shmem_backing_dev_info  __read_mostly = {
 	.ra_pages	= 0,	/* No readahead */
@@ -2498,7 +2498,7 @@ static const struct super_operations shmem_ops = {
 	.put_super	= shmem_put_super,
 };
 
-static struct vm_operations_struct shmem_vm_ops = {
+static const struct vm_operations_struct shmem_vm_ops = {
 	.fault		= shmem_fault,
 #ifdef CONFIG_NUMA
 	.set_policy     = shmem_set_policy,
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2084,7 +2084,7 @@ static void packet_mm_close(struct vm_area_struct *vma)
 		atomic_dec(&pkt_sk(sk)->mapped);
 }
 
-static struct vm_operations_struct packet_mmap_ops = {
+static const struct vm_operations_struct packet_mmap_ops = {
 	.open	=	packet_mm_open,
 	.close	=	packet_mm_close,
 };
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -2985,7 +2985,7 @@ static int snd_pcm_mmap_status_fault(struct vm_area_struct *area,
 	return 0;
 }
 
-static struct vm_operations_struct snd_pcm_vm_ops_status =
+static const struct vm_operations_struct snd_pcm_vm_ops_status =
 {
 	.fault =	snd_pcm_mmap_status_fault,
 };
@@ -3024,7 +3024,7 @@ static int snd_pcm_mmap_control_fault(struct vm_area_struct *area,
 	return 0;
 }
 
-static struct vm_operations_struct snd_pcm_vm_ops_control =
+static const struct vm_operations_struct snd_pcm_vm_ops_control =
 {
 	.fault =	snd_pcm_mmap_control_fault,
 };
@@ -3094,7 +3094,7 @@ static int snd_pcm_mmap_data_fault(struct vm_area_struct *area,
 	return 0;
 }
 
-static struct vm_operations_struct snd_pcm_vm_ops_data =
+static const struct vm_operations_struct snd_pcm_vm_ops_data =
 {
 	.open =		snd_pcm_mmap_data_open,
 	.close =	snd_pcm_mmap_data_close,
@@ -3118,7 +3118,7 @@ static int snd_pcm_default_mmap(struct snd_pcm_substream *substream,
  * mmap the DMA buffer on I/O memory area
  */
 #if SNDRV_PCM_INFO_MMAP_IOMEM
-static struct vm_operations_struct snd_pcm_vm_ops_data_mmio =
+static const struct vm_operations_struct snd_pcm_vm_ops_data_mmio =
 {
 	.open =		snd_pcm_mmap_data_open,
 	.close =	snd_pcm_mmap_data_close,
--- a/sound/usb/usx2y/us122l.c
+++ b/sound/usb/usx2y/us122l.c
@@ -154,7 +154,7 @@ static void usb_stream_hwdep_vm_close(struct vm_area_struct *area)
 	snd_printdd(KERN_DEBUG "%i\n", atomic_read(&us122l->mmap_count));
 }
 
-static struct vm_operations_struct usb_stream_hwdep_vm_ops = {
+static const struct vm_operations_struct usb_stream_hwdep_vm_ops = {
 	.open = usb_stream_hwdep_vm_open,
 	.fault = usb_stream_hwdep_vm_fault,
 	.close = usb_stream_hwdep_vm_close,
--- a/sound/usb/usx2y/usX2Yhwdep.c
+++ b/sound/usb/usx2y/usX2Yhwdep.c
@@ -53,7 +53,7 @@ static int snd_us428ctls_vm_fault(struct vm_area_struct *area,
 	return 0;
 }
 
-static struct vm_operations_struct us428ctls_vm_ops = {
+static const struct vm_operations_struct us428ctls_vm_ops = {
 	.fault = snd_us428ctls_vm_fault,
 };
 
--- a/sound/usb/usx2y/usx2yhwdeppcm.c
+++ b/sound/usb/usx2y/usx2yhwdeppcm.c
@@ -697,7 +697,7 @@ static int snd_usX2Y_hwdep_pcm_vm_fault(struct vm_area_struct *area,
 }
 
 
-static struct vm_operations_struct snd_usX2Y_hwdep_pcm_vm_ops = {
+static const struct vm_operations_struct snd_usX2Y_hwdep_pcm_vm_ops = {
 	.open = snd_usX2Y_hwdep_pcm_vm_open,
 	.close = snd_usX2Y_hwdep_pcm_vm_close,
 	.fault = snd_usX2Y_hwdep_pcm_vm_fault,
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1713,7 +1713,7 @@ static int kvm_vcpu_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct kvm_vcpu_vm_ops = {
+static const struct vm_operations_struct kvm_vcpu_vm_ops = {
 	.fault = kvm_vcpu_fault,
 };
 
@@ -2317,7 +2317,7 @@ static int kvm_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct kvm_vm_vm_ops = {
+static const struct vm_operations_struct kvm_vm_vm_ops = {
 	.fault = kvm_vm_fault,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
