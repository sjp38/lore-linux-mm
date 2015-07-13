Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DF5DC6B0254
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:54:17 -0400 (EDT)
Received: by pacan13 with SMTP id an13so14165435pac.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 03:54:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 4si27800277pdk.216.2015.07.13.03.54.16
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 03:54:16 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/5] mm: mark most vm_operations_struct const
Date: Mon, 13 Jul 2015 13:54:08 +0300
Message-Id: <1436784852-144369-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With two excetions (drm/qxl and drm/radeon) all vm_operations_struct
structs should be constant.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/vsyscall_64.c                  | 2 +-
 drivers/android/binder.c                       | 2 +-
 drivers/gpu/drm/vgem/vgem_drv.c                | 2 +-
 drivers/hsi/clients/cmt_speech.c               | 2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c       | 2 +-
 drivers/infiniband/hw/qib/qib_mmap.c           | 2 +-
 drivers/media/platform/omap/omap_vout.c        | 2 +-
 drivers/misc/genwqe/card_dev.c                 | 2 +-
 drivers/staging/android/ion/ion.c              | 2 +-
 drivers/staging/comedi/comedi_fops.c           | 2 +-
 drivers/video/fbdev/omap2/omapfb/omapfb-main.c | 2 +-
 drivers/xen/gntalloc.c                         | 2 +-
 drivers/xen/gntdev.c                           | 2 +-
 drivers/xen/privcmd.c                          | 4 ++--
 fs/ceph/addr.c                                 | 2 +-
 fs/cifs/file.c                                 | 2 +-
 security/selinux/selinuxfs.c                   | 2 +-
 17 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/arch/x86/kernel/vsyscall_64.c b/arch/x86/kernel/vsyscall_64.c
index 2dcc6ff6fdcc..30f3a83291ad 100644
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -277,7 +277,7 @@ static const char *gate_vma_name(struct vm_area_struct *vma)
 {
 	return "[vsyscall]";
 }
-static struct vm_operations_struct gate_vma_ops = {
+static const struct vm_operations_struct gate_vma_ops = {
 	.name = gate_vma_name,
 };
 static struct vm_area_struct gate_vma = {
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index 6607f3c6ace1..a39e85f9efa9 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -2834,7 +2834,7 @@ static int binder_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return VM_FAULT_SIGBUS;
 }
 
-static struct vm_operations_struct binder_vm_ops = {
+static const struct vm_operations_struct binder_vm_ops = {
 	.open = binder_vma_open,
 	.close = binder_vma_close,
 	.fault = binder_vm_fault,
diff --git a/drivers/gpu/drm/vgem/vgem_drv.c b/drivers/gpu/drm/vgem/vgem_drv.c
index 7a207ca547be..27c2c473d9d3 100644
--- a/drivers/gpu/drm/vgem/vgem_drv.c
+++ b/drivers/gpu/drm/vgem/vgem_drv.c
@@ -125,7 +125,7 @@ static int vgem_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 }
 
-static struct vm_operations_struct vgem_gem_vm_ops = {
+static const struct vm_operations_struct vgem_gem_vm_ops = {
 	.fault = vgem_gem_fault,
 	.open = drm_gem_vm_open,
 	.close = drm_gem_vm_close,
diff --git a/drivers/hsi/clients/cmt_speech.c b/drivers/hsi/clients/cmt_speech.c
index 4983529a9c6c..914b2c2d1f2d 100644
--- a/drivers/hsi/clients/cmt_speech.c
+++ b/drivers/hsi/clients/cmt_speech.c
@@ -1105,7 +1105,7 @@ static int cs_char_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct cs_char_vm_ops = {
+static const struct vm_operations_struct cs_char_vm_ops = {
 	.fault	= cs_char_vma_fault,
 };
 
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index 725881890c4a..e449e394963f 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -908,7 +908,7 @@ static int qib_file_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
-static struct vm_operations_struct qib_file_vm_ops = {
+static const struct vm_operations_struct qib_file_vm_ops = {
 	.fault = qib_file_vma_fault,
 };
 
diff --git a/drivers/infiniband/hw/qib/qib_mmap.c b/drivers/infiniband/hw/qib/qib_mmap.c
index 146cf29a2e1d..34927b700b0e 100644
--- a/drivers/infiniband/hw/qib/qib_mmap.c
+++ b/drivers/infiniband/hw/qib/qib_mmap.c
@@ -75,7 +75,7 @@ static void qib_vma_close(struct vm_area_struct *vma)
 	kref_put(&ip->ref, qib_release_mmap_info);
 }
 
-static struct vm_operations_struct qib_vm_ops = {
+static const struct vm_operations_struct qib_vm_ops = {
 	.open =     qib_vma_open,
 	.close =    qib_vma_close,
 };
diff --git a/drivers/media/platform/omap/omap_vout.c b/drivers/media/platform/omap/omap_vout.c
index 17b189a81ec5..38a50df8d629 100644
--- a/drivers/media/platform/omap/omap_vout.c
+++ b/drivers/media/platform/omap/omap_vout.c
@@ -876,7 +876,7 @@ static void omap_vout_vm_close(struct vm_area_struct *vma)
 	vout->mmap_count--;
 }
 
-static struct vm_operations_struct omap_vout_vm_ops = {
+static const struct vm_operations_struct omap_vout_vm_ops = {
 	.open	= omap_vout_vm_open,
 	.close	= omap_vout_vm_close,
 };
diff --git a/drivers/misc/genwqe/card_dev.c b/drivers/misc/genwqe/card_dev.c
index c49d244265ec..70e62d6a3231 100644
--- a/drivers/misc/genwqe/card_dev.c
+++ b/drivers/misc/genwqe/card_dev.c
@@ -418,7 +418,7 @@ static void genwqe_vma_close(struct vm_area_struct *vma)
 	kfree(dma_map);
 }
 
-static struct vm_operations_struct genwqe_vma_ops = {
+static const struct vm_operations_struct genwqe_vma_ops = {
 	.open   = genwqe_vma_open,
 	.close  = genwqe_vma_close,
 };
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index b0b96ab31954..2bbfed9acf19 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -997,7 +997,7 @@ static void ion_vm_close(struct vm_area_struct *vma)
 	mutex_unlock(&buffer->lock);
 }
 
-static struct vm_operations_struct ion_vma_ops = {
+static const struct vm_operations_struct ion_vma_ops = {
 	.open = ion_vm_open,
 	.close = ion_vm_close,
 	.fault = ion_vm_fault,
diff --git a/drivers/staging/comedi/comedi_fops.c b/drivers/staging/comedi/comedi_fops.c
index e78ddbe5a954..1649665eb633 100644
--- a/drivers/staging/comedi/comedi_fops.c
+++ b/drivers/staging/comedi/comedi_fops.c
@@ -2127,7 +2127,7 @@ static void comedi_vm_close(struct vm_area_struct *area)
 	comedi_buf_map_put(bm);
 }
 
-static struct vm_operations_struct comedi_vm_ops = {
+static const struct vm_operations_struct comedi_vm_ops = {
 	.open = comedi_vm_open,
 	.close = comedi_vm_close,
 };
diff --git a/drivers/video/fbdev/omap2/omapfb/omapfb-main.c b/drivers/video/fbdev/omap2/omapfb/omapfb-main.c
index 4f0cbb54d4db..d3af01c94a58 100644
--- a/drivers/video/fbdev/omap2/omapfb/omapfb-main.c
+++ b/drivers/video/fbdev/omap2/omapfb/omapfb-main.c
@@ -1091,7 +1091,7 @@ static void mmap_user_close(struct vm_area_struct *vma)
 	omapfb_put_mem_region(rg);
 }
 
-static struct vm_operations_struct mmap_user_ops = {
+static const struct vm_operations_struct mmap_user_ops = {
 	.open = mmap_user_open,
 	.close = mmap_user_close,
 };
diff --git a/drivers/xen/gntalloc.c b/drivers/xen/gntalloc.c
index e53fe191738c..696301d9dc91 100644
--- a/drivers/xen/gntalloc.c
+++ b/drivers/xen/gntalloc.c
@@ -493,7 +493,7 @@ static void gntalloc_vma_close(struct vm_area_struct *vma)
 	mutex_unlock(&gref_mutex);
 }
 
-static struct vm_operations_struct gntalloc_vmops = {
+static const struct vm_operations_struct gntalloc_vmops = {
 	.open = gntalloc_vma_open,
 	.close = gntalloc_vma_close,
 };
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 89274850741b..b112d529a2d1 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -433,7 +433,7 @@ static struct page *gntdev_vma_find_special_page(struct vm_area_struct *vma,
 	return map->pages[(addr - map->pages_vm_start) >> PAGE_SHIFT];
 }
 
-static struct vm_operations_struct gntdev_vmops = {
+static const struct vm_operations_struct gntdev_vmops = {
 	.open = gntdev_vma_open,
 	.close = gntdev_vma_close,
 	.find_special_page = gntdev_vma_find_special_page,
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 5a296161d843..56cb13fcbd0e 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -414,7 +414,7 @@ static int alloc_empty_pages(struct vm_area_struct *vma, int numpgs)
 	return 0;
 }
 
-static struct vm_operations_struct privcmd_vm_ops;
+static const struct vm_operations_struct privcmd_vm_ops;
 
 static long privcmd_ioctl_mmap_batch(void __user *udata, int version)
 {
@@ -605,7 +605,7 @@ static int privcmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return VM_FAULT_SIGBUS;
 }
 
-static struct vm_operations_struct privcmd_vm_ops = {
+static const struct vm_operations_struct privcmd_vm_ops = {
 	.close = privcmd_close,
 	.fault = privcmd_fault
 };
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index e162bcd105ee..9fa7b3812851 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1582,7 +1582,7 @@ out:
 	return err;
 }
 
-static struct vm_operations_struct ceph_vmops = {
+static const struct vm_operations_struct ceph_vmops = {
 	.fault		= ceph_filemap_fault,
 	.page_mkwrite	= ceph_page_mkwrite,
 };
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 2ac2d8471393..94f81962368c 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3216,7 +3216,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return VM_FAULT_LOCKED;
 }
 
-static struct vm_operations_struct cifs_file_vm_ops = {
+static const struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
 	.map_pages = filemap_map_pages,
 	.page_mkwrite = cifs_page_mkwrite,
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index d2787cca1fcb..0538f7034ef2 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -472,7 +472,7 @@ static int sel_mmap_policy_fault(struct vm_area_struct *vma,
 	return 0;
 }
 
-static struct vm_operations_struct sel_mmap_policy_ops = {
+static const struct vm_operations_struct sel_mmap_policy_ops = {
 	.fault = sel_mmap_policy_fault,
 	.page_mkwrite = sel_mmap_policy_fault,
 };
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
