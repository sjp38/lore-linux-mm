Date: Tue, 28 Nov 2006 16:45:02 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004502.11682.75882.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
References: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 7/8] Get rid of SLAB_KERNEL
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Get rid of SLAB_KERNEL

SLAB_KERNEL is an alias of GFP_KERNEL.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/arch/sh/kernel/vsyscall/vsyscall.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/sh/kernel/vsyscall/vsyscall.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/sh/kernel/vsyscall/vsyscall.c	2006-11-28 16:11:23.000000000 -0800
@@ -97,7 +97,7 @@
 		goto up_fail;
 	}
 
-	vma = kmem_cache_zalloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma) {
 		ret = -ENOMEM;
 		goto up_fail;
Index: linux-2.6.19-rc6-mm1/arch/i386/kernel/sysenter.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/i386/kernel/sysenter.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/i386/kernel/sysenter.c	2006-11-28 16:11:23.000000000 -0800
@@ -136,7 +136,7 @@
 		goto up_fail;
 	}
 
-	vma = kmem_cache_zalloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma) {
 		ret = -ENOMEM;
 		goto up_fail;
Index: linux-2.6.19-rc6-mm1/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/ia64/mm/init.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/ia64/mm/init.c	2006-11-28 16:11:23.000000000 -0800
@@ -156,7 +156,7 @@
 	 * the problem.  When the process attempts to write to the register backing store
 	 * for the first time, it will get a SEGFAULT in this case.
 	 */
-	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
 		memset(vma, 0, sizeof(*vma));
 		vma->vm_mm = current->mm;
@@ -175,7 +175,7 @@
 
 	/* map NaT-page at address zero to speed up speculative dereferencing of NULL: */
 	if (!(current->personality & MMAP_PAGE_ZERO)) {
-		vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+		vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (vma) {
 			memset(vma, 0, sizeof(*vma));
 			vma->vm_mm = current->mm;
Index: linux-2.6.19-rc6-mm1/arch/ia64/ia32/binfmt_elf32.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/ia64/ia32/binfmt_elf32.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/ia64/ia32/binfmt_elf32.c	2006-11-28 16:11:23.000000000 -0800
@@ -91,7 +91,7 @@
 	 * it with privilege level 3 because the IVE uses non-privileged accesses to these
 	 * tables.  IA-32 segmentation is used to protect against IA-32 accesses to them.
 	 */
-	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
 		memset(vma, 0, sizeof(*vma));
 		vma->vm_mm = current->mm;
@@ -117,7 +117,7 @@
 	 * code is locked in specific gate page, which is pointed by pretcode
 	 * when setup_frame_ia32
 	 */
-	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
 		memset(vma, 0, sizeof(*vma));
 		vma->vm_mm = current->mm;
@@ -142,7 +142,7 @@
 	 * Install LDT as anonymous memory.  This gives us all-zero segment descriptors
 	 * until a task modifies them via modify_ldt().
 	 */
-	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (vma) {
 		memset(vma, 0, sizeof(*vma));
 		vma->vm_mm = current->mm;
@@ -214,7 +214,7 @@
 		bprm->loader += stack_base;
 	bprm->exec += stack_base;
 
-	mpnt = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	mpnt = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!mpnt)
 		return -ENOMEM;
 
Index: linux-2.6.19-rc6-mm1/arch/ia64/kernel/perfmon.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/ia64/kernel/perfmon.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/ia64/kernel/perfmon.c	2006-11-28 16:11:23.000000000 -0800
@@ -2302,7 +2302,7 @@
 	DPRINT(("smpl_buf @%p\n", smpl_buf));
 
 	/* allocate vma */
-	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma) {
 		DPRINT(("Cannot allocate vma\n"));
 		goto error_kmem;
Index: linux-2.6.19-rc6-mm1/arch/x86_64/ia32/ia32_binfmt.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/x86_64/ia32/ia32_binfmt.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/x86_64/ia32/ia32_binfmt.c	2006-11-28 16:11:23.000000000 -0800
@@ -349,7 +349,7 @@
 		bprm->loader += stack_base;
 	bprm->exec += stack_base;
 
-	mpnt = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	mpnt = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!mpnt) 
 		return -ENOMEM; 
 
Index: linux-2.6.19-rc6-mm1/arch/x86_64/ia32/syscall32.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/x86_64/ia32/syscall32.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/x86_64/ia32/syscall32.c	2006-11-28 16:11:23.000000000 -0800
@@ -49,7 +49,7 @@
 	struct mm_struct *mm = current->mm;
 	int ret;
 
-	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma)
 		return -ENOMEM;
 
Index: linux-2.6.19-rc6-mm1/arch/powerpc/platforms/cell/spufs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/powerpc/platforms/cell/spufs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/powerpc/platforms/cell/spufs/inode.c	2006-11-28 16:11:23.000000000 -0800
@@ -48,7 +48,7 @@
 {
 	struct spufs_inode_info *ei;
 
-	ei = kmem_cache_alloc(spufs_inode_cache, SLAB_KERNEL);
+	ei = kmem_cache_alloc(spufs_inode_cache, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/arch/powerpc/kernel/vdso.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/powerpc/kernel/vdso.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/powerpc/kernel/vdso.c	2006-11-28 16:11:23.000000000 -0800
@@ -264,7 +264,7 @@
 
 
 	/* Allocate a VMA structure and fill it up */
-	vma = kmem_cache_zalloc(vm_area_cachep, SLAB_KERNEL);
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (vma == NULL) {
 		rc = -ENOMEM;
 		goto fail_mmapsem;
Index: linux-2.6.19-rc6-mm1/drivers/atm/he.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/atm/he.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/atm/he.c	2006-11-28 16:11:23.000000000 -0800
@@ -820,7 +820,7 @@
 		void *cpuaddr;
 
 #ifdef USE_RBPS_POOL 
-		cpuaddr = pci_pool_alloc(he_dev->rbps_pool, SLAB_KERNEL|SLAB_DMA, &dma_handle);
+		cpuaddr = pci_pool_alloc(he_dev->rbps_pool, GFP_KERNEL|SLAB_DMA, &dma_handle);
 		if (cpuaddr == NULL)
 			return -ENOMEM;
 #else
@@ -884,7 +884,7 @@
 		void *cpuaddr;
 
 #ifdef USE_RBPL_POOL
-		cpuaddr = pci_pool_alloc(he_dev->rbpl_pool, SLAB_KERNEL|SLAB_DMA, &dma_handle);
+		cpuaddr = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|SLAB_DMA, &dma_handle);
 		if (cpuaddr == NULL)
 			return -ENOMEM;
 #else
Index: linux-2.6.19-rc6-mm1/drivers/dma/ioatdma.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/dma/ioatdma.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/dma/ioatdma.c	2006-11-28 16:11:23.000000000 -0800
@@ -630,10 +630,10 @@
 	dma_cookie_t cookie;
 	int err = 0;
 
-	src = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, SLAB_KERNEL);
+	src = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, GFP_KERNEL);
 	if (!src)
 		return -ENOMEM;
-	dest = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, SLAB_KERNEL);
+	dest = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, GFP_KERNEL);
 	if (!dest) {
 		kfree(src);
 		return -ENOMEM;
Index: linux-2.6.19-rc6-mm1/drivers/mtd/devices/m25p80.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/mtd/devices/m25p80.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/mtd/devices/m25p80.c	2006-11-28 16:11:23.000000000 -0800
@@ -451,7 +451,7 @@
 		return -ENODEV;
 	}
 
-	flash = kzalloc(sizeof *flash, SLAB_KERNEL);
+	flash = kzalloc(sizeof *flash, GFP_KERNEL);
 	if (!flash)
 		return -ENOMEM;
 
Index: linux-2.6.19-rc6-mm1/drivers/spi/spi.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/spi/spi.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/spi/spi.c	2006-11-28 16:11:23.000000000 -0800
@@ -360,7 +360,7 @@
 	if (!dev)
 		return NULL;
 
-	master = kzalloc(size + sizeof *master, SLAB_KERNEL);
+	master = kzalloc(size + sizeof *master, GFP_KERNEL);
 	if (!master)
 		return NULL;
 
@@ -608,7 +608,7 @@
 {
 	int	status;
 
-	buf = kmalloc(SPI_BUFSIZ, SLAB_KERNEL);
+	buf = kmalloc(SPI_BUFSIZ, GFP_KERNEL);
 	if (!buf) {
 		status = -ENOMEM;
 		goto err0;
Index: linux-2.6.19-rc6-mm1/drivers/spi/spi_bitbang.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/spi/spi_bitbang.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/spi/spi_bitbang.c	2006-11-28 16:11:23.000000000 -0800
@@ -196,7 +196,7 @@
 		return -EINVAL;
 
 	if (!cs) {
-		cs = kzalloc(sizeof *cs, SLAB_KERNEL);
+		cs = kzalloc(sizeof *cs, GFP_KERNEL);
 		if (!cs)
 			return -ENOMEM;
 		spi->controller_state = cs;
Index: linux-2.6.19-rc6-mm1/drivers/usb/net/rndis_host.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/net/rndis_host.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/net/rndis_host.c	2006-11-28 16:11:23.000000000 -0800
@@ -469,7 +469,7 @@
 	struct rndis_halt	*halt;
 
 	/* try to clear any rndis state/activity (no i/o from stack!) */
-	halt = kcalloc(1, sizeof *halt, SLAB_KERNEL);
+	halt = kcalloc(1, sizeof *halt, GFP_KERNEL);
 	if (halt) {
 		halt->msg_type = RNDIS_MSG_HALT;
 		halt->msg_len = ccpu2(sizeof *halt);
Index: linux-2.6.19-rc6-mm1/drivers/usb/net/usbnet.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/net/usbnet.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/net/usbnet.c	2006-11-28 16:11:23.000000000 -0800
@@ -179,9 +179,9 @@
 	period = max ((int) dev->status->desc.bInterval,
 		(dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
 
-	buf = kmalloc (maxp, SLAB_KERNEL);
+	buf = kmalloc (maxp, GFP_KERNEL);
 	if (buf) {
-		dev->interrupt = usb_alloc_urb (0, SLAB_KERNEL);
+		dev->interrupt = usb_alloc_urb (0, GFP_KERNEL);
 		if (!dev->interrupt) {
 			kfree (buf);
 			return -ENOMEM;
Index: linux-2.6.19-rc6-mm1/drivers/usb/core/hub.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/core/hub.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/core/hub.c	2006-11-28 16:11:23.000000000 -0800
@@ -2357,7 +2357,7 @@
 	struct usb_qualifier_descriptor	*qual;
 	int				status;
 
-	qual = kmalloc (sizeof *qual, SLAB_KERNEL);
+	qual = kmalloc (sizeof *qual, GFP_KERNEL);
 	if (qual == NULL)
 		return;
 
@@ -2908,7 +2908,7 @@
 		if (len < le16_to_cpu(udev->config[index].desc.wTotalLength))
 			len = le16_to_cpu(udev->config[index].desc.wTotalLength);
 	}
-	buf = kmalloc (len, SLAB_KERNEL);
+	buf = kmalloc (len, GFP_KERNEL);
 	if (buf == NULL) {
 		dev_err(&udev->dev, "no mem to re-read configs after reset\n");
 		/* assume the worst */
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/ohci-pnx4008.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/ohci-pnx4008.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/ohci-pnx4008.c	2006-11-28 16:11:23.000000000 -0800
@@ -134,7 +134,7 @@
 {
 	struct i2c_client *c;
 
-	c = (struct i2c_client *)kzalloc(sizeof(*c), SLAB_KERNEL);
+	c = (struct i2c_client *)kzalloc(sizeof(*c), GFP_KERNEL);
 
 	if (!c)
 		return -ENOMEM;
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/hc_crisv10.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/hc_crisv10.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/hc_crisv10.c	2006-11-28 16:11:23.000000000 -0800
@@ -188,7 +188,7 @@
 #define CHECK_ALIGN(x) if (((__u32)(x)) & 0x00000003) \
 {panic("Alignment check (DWORD) failed at %s:%s:%d\n", __FILE__, __FUNCTION__, __LINE__);}
 
-#define SLAB_FLAG     (in_interrupt() ? GFP_ATOMIC : SLAB_KERNEL)
+#define SLAB_FLAG     (in_interrupt() ? GFP_ATOMIC : GFP_KERNEL)
 #define KMALLOC_FLAG  (in_interrupt() ? GFP_ATOMIC : GFP_KERNEL)
 
 /* Most helpful debugging aid */
Index: linux-2.6.19-rc6-mm1/drivers/usb/misc/usbtest.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/misc/usbtest.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/misc/usbtest.c	2006-11-28 16:11:23.000000000 -0800
@@ -213,7 +213,7 @@
 
 	if (bytes < 0)
 		return NULL;
-	urb = usb_alloc_urb (0, SLAB_KERNEL);
+	urb = usb_alloc_urb (0, GFP_KERNEL);
 	if (!urb)
 		return urb;
 	usb_fill_bulk_urb (urb, udev, pipe, NULL, bytes, simple_callback, NULL);
@@ -223,7 +223,7 @@
 	urb->transfer_flags = URB_NO_TRANSFER_DMA_MAP;
 	if (usb_pipein (pipe))
 		urb->transfer_flags |= URB_SHORT_NOT_OK;
-	urb->transfer_buffer = usb_buffer_alloc (udev, bytes, SLAB_KERNEL,
+	urb->transfer_buffer = usb_buffer_alloc (udev, bytes, GFP_KERNEL,
 			&urb->transfer_dma);
 	if (!urb->transfer_buffer) {
 		usb_free_urb (urb);
@@ -315,7 +315,7 @@
 		init_completion (&completion);
 		if (usb_pipeout (urb->pipe))
 			simple_fill_buf (urb);
-		if ((retval = usb_submit_urb (urb, SLAB_KERNEL)) != 0)
+		if ((retval = usb_submit_urb (urb, GFP_KERNEL)) != 0)
 			break;
 
 		/* NOTE:  no timeouts; can't be broken out of by interrupt */
@@ -374,7 +374,7 @@
 	unsigned		i;
 	unsigned		size = max;
 
-	sg = kmalloc (nents * sizeof *sg, SLAB_KERNEL);
+	sg = kmalloc (nents * sizeof *sg, GFP_KERNEL);
 	if (!sg)
 		return NULL;
 
@@ -382,7 +382,7 @@
 		char		*buf;
 		unsigned	j;
 
-		buf = kzalloc (size, SLAB_KERNEL);
+		buf = kzalloc (size, GFP_KERNEL);
 		if (!buf) {
 			free_sglist (sg, i);
 			return NULL;
@@ -428,7 +428,7 @@
 				(udev->speed == USB_SPEED_HIGH)
 					? (INTERRUPT_RATE << 3)
 					: INTERRUPT_RATE,
-				sg, nents, 0, SLAB_KERNEL);
+				sg, nents, 0, GFP_KERNEL);
 		
 		if (retval)
 			break;
@@ -855,7 +855,7 @@
 	 * as with bulk/intr sglists, sglen is the queue depth; it also
 	 * controls which subtests run (more tests than sglen) or rerun.
 	 */
-	urb = kcalloc(param->sglen, sizeof(struct urb *), SLAB_KERNEL);
+	urb = kcalloc(param->sglen, sizeof(struct urb *), GFP_KERNEL);
 	if (!urb)
 		return -ENOMEM;
 	for (i = 0; i < param->sglen; i++) {
@@ -981,7 +981,7 @@
 		if (!u)
 			goto cleanup;
 
-		reqp = usb_buffer_alloc (udev, sizeof *reqp, SLAB_KERNEL,
+		reqp = usb_buffer_alloc (udev, sizeof *reqp, GFP_KERNEL,
 				&u->setup_dma);
 		if (!reqp)
 			goto cleanup;
@@ -1067,7 +1067,7 @@
 	 * FIXME want additional tests for when endpoint is STALLing
 	 * due to errors, or is just NAKing requests.
 	 */
-	if ((retval = usb_submit_urb (urb, SLAB_KERNEL)) != 0) {
+	if ((retval = usb_submit_urb (urb, GFP_KERNEL)) != 0) {
 		dev_dbg (&dev->intf->dev, "submit fail %d\n", retval);
 		return retval;
 	}
@@ -1251,7 +1251,7 @@
 	if (length < 1 || length > 0xffff || vary >= length)
 		return -EINVAL;
 
-	buf = kmalloc(length, SLAB_KERNEL);
+	buf = kmalloc(length, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
@@ -1403,7 +1403,7 @@
 	maxp *= 1 + (0x3 & (le16_to_cpu(desc->wMaxPacketSize) >> 11));
 	packets = (bytes + maxp - 1) / maxp;
 
-	urb = usb_alloc_urb (packets, SLAB_KERNEL);
+	urb = usb_alloc_urb (packets, GFP_KERNEL);
 	if (!urb)
 		return urb;
 	urb->dev = udev;
@@ -1411,7 +1411,7 @@
 
 	urb->number_of_packets = packets;
 	urb->transfer_buffer_length = bytes;
-	urb->transfer_buffer = usb_buffer_alloc (udev, bytes, SLAB_KERNEL,
+	urb->transfer_buffer = usb_buffer_alloc (udev, bytes, GFP_KERNEL,
 			&urb->transfer_dma);
 	if (!urb->transfer_buffer) {
 		usb_free_urb (urb);
@@ -1900,7 +1900,7 @@
 	}
 #endif
 
-	dev = kzalloc(sizeof(*dev), SLAB_KERNEL);
+	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
 	if (!dev)
 		return -ENOMEM;
 	info = (struct usbtest_info *) id->driver_info;
@@ -1910,7 +1910,7 @@
 	dev->intf = intf;
 
 	/* cacheline-aligned scratch for i/o */
-	if ((dev->buf = kmalloc (TBUF_SIZE, SLAB_KERNEL)) == NULL) {
+	if ((dev->buf = kmalloc (TBUF_SIZE, GFP_KERNEL)) == NULL) {
 		kfree (dev);
 		return -ENOMEM;
 	}
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/acecad.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/acecad.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/acecad.c	2006-11-28 16:11:23.000000000 -0800
@@ -152,7 +152,7 @@
 	if (!acecad || !input_dev)
 		goto fail1;
 
-	acecad->data = usb_buffer_alloc(dev, 8, SLAB_KERNEL, &acecad->data_dma);
+	acecad->data = usb_buffer_alloc(dev, 8, GFP_KERNEL, &acecad->data_dma);
 	if (!acecad->data)
 		goto fail1;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/usbtouchscreen.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/usbtouchscreen.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/usbtouchscreen.c	2006-11-28 16:11:23.000000000 -0800
@@ -680,7 +680,7 @@
 		type->process_pkt = usbtouch_process_pkt;
 
 	usbtouch->data = usb_buffer_alloc(udev, type->rept_size,
-	                                  SLAB_KERNEL, &usbtouch->data_dma);
+	                                  GFP_KERNEL, &usbtouch->data_dma);
 	if (!usbtouch->data)
 		goto out_free;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/gadget/gmidi.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/gadget/gmidi.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/gadget/gmidi.c	2006-11-28 16:11:23.000000000 -0800
@@ -1236,7 +1236,7 @@
 
 
 	/* ok, we made sense of the hardware ... */
-	dev = kzalloc(sizeof(*dev), SLAB_KERNEL);
+	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
 	if (!dev) {
 		return -ENOMEM;
 	}
Index: linux-2.6.19-rc6-mm1/drivers/usb/gadget/net2280.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/gadget/net2280.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/gadget/net2280.c	2006-11-28 16:11:23.000000000 -0800
@@ -2857,7 +2857,7 @@
 	}
 
 	/* alloc, and start init */
-	dev = kzalloc (sizeof *dev, SLAB_KERNEL);
+	dev = kzalloc (sizeof *dev, GFP_KERNEL);
 	if (dev == NULL){
 		retval = -ENOMEM;
 		goto done;
Index: linux-2.6.19-rc6-mm1/drivers/usb/gadget/goku_udc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/gadget/goku_udc.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/gadget/goku_udc.c	2006-11-28 16:11:23.000000000 -0800
@@ -1864,7 +1864,7 @@
 	}
 
 	/* alloc, and start init */
-	dev = kmalloc (sizeof *dev, SLAB_KERNEL);
+	dev = kmalloc (sizeof *dev, GFP_KERNEL);
 	if (dev == NULL){
 		pr_debug("enomem %s\n", pci_name(pdev));
 		retval = -ENOMEM;
Index: linux-2.6.19-rc6-mm1/drivers/usb/gadget/zero.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/gadget/zero.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/gadget/zero.c	2006-11-28 16:11:23.000000000 -0800
@@ -1190,7 +1190,7 @@
 
 
 	/* ok, we made sense of the hardware ... */
-	dev = kzalloc(sizeof(*dev), SLAB_KERNEL);
+	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
 	if (!dev)
 		return -ENOMEM;
 	spin_lock_init (&dev->lock);
Index: linux-2.6.19-rc6-mm1/drivers/usb/gadget/omap_udc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/gadget/omap_udc.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/gadget/omap_udc.c	2006-11-28 16:11:23.000000000 -0800
@@ -2581,7 +2581,7 @@
 	/* UDC_PULLUP_EN gates the chip clock */
 	// OTG_SYSCON_1_REG |= DEV_IDLE_EN;
 
-	udc = kzalloc(sizeof(*udc), SLAB_KERNEL);
+	udc = kzalloc(sizeof(*udc), GFP_KERNEL);
 	if (!udc)
 		return -ENOMEM;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/gadget/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/gadget/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/gadget/inode.c	2006-11-28 16:11:23.000000000 -0800
@@ -412,7 +412,7 @@
 	/* FIXME readahead for O_NONBLOCK and poll(); careful with ZLPs */
 
 	value = -ENOMEM;
-	kbuf = kmalloc (len, SLAB_KERNEL);
+	kbuf = kmalloc (len, GFP_KERNEL);
 	if (unlikely (!kbuf))
 		goto free1;
 
@@ -456,7 +456,7 @@
 	/* FIXME writebehind for O_NONBLOCK and poll(), qlen = 1 */
 
 	value = -ENOMEM;
-	kbuf = kmalloc (len, SLAB_KERNEL);
+	kbuf = kmalloc (len, GFP_KERNEL);
 	if (!kbuf)
 		goto free1;
 	if (copy_from_user (kbuf, buf, len)) {
@@ -1898,7 +1898,7 @@
 	buf += 4;
 	length -= 4;
 
-	kbuf = kmalloc (length, SLAB_KERNEL);
+	kbuf = kmalloc (length, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
 	if (copy_from_user (kbuf, buf, length)) {
Index: linux-2.6.19-rc6-mm1/drivers/base/dmapool.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/base/dmapool.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/base/dmapool.c	2006-11-28 16:11:23.000000000 -0800
@@ -126,7 +126,7 @@
 	} else if (allocation < size)
 		return NULL;
 
-	if (!(retval = kmalloc (sizeof *retval, SLAB_KERNEL)))
+	if (!(retval = kmalloc (sizeof *retval, GFP_KERNEL)))
 		return retval;
 
 	strlcpy (retval->name, name, sizeof retval->name);
Index: linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/usb-gigaset.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/isdn/gigaset/usb-gigaset.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/usb-gigaset.c	2006-11-28 16:11:23.000000000 -0800
@@ -763,7 +763,7 @@
 		goto error;
 	}
 
-	ucs->bulk_out_urb = usb_alloc_urb(0, SLAB_KERNEL);
+	ucs->bulk_out_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!ucs->bulk_out_urb) {
 		dev_err(cs->dev, "Couldn't allocate bulk_out_urb\n");
 		retval = -ENOMEM;
@@ -774,7 +774,7 @@
 
 	atomic_set(&ucs->busy, 0);
 
-	ucs->read_urb = usb_alloc_urb(0, SLAB_KERNEL);
+	ucs->read_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!ucs->read_urb) {
 		dev_err(cs->dev, "No free urbs available\n");
 		retval = -ENOMEM;
@@ -797,7 +797,7 @@
 			 gigaset_read_int_callback,
 			 cs->inbuf + 0, endpoint->bInterval);
 
-	retval = usb_submit_urb(ucs->read_urb, SLAB_KERNEL);
+	retval = usb_submit_urb(ucs->read_urb, GFP_KERNEL);
 	if (retval) {
 		dev_err(cs->dev, "Could not submit URB (error %d)\n", -retval);
 		goto error;
Index: linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/bas-gigaset.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/isdn/gigaset/bas-gigaset.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/bas-gigaset.c	2006-11-28 16:11:23.000000000 -0800
@@ -2218,21 +2218,21 @@
 	 * - three for the different uses of the default control pipe
 	 * - three for each isochronous pipe
 	 */
-	if (!(ucs->urb_int_in = usb_alloc_urb(0, SLAB_KERNEL)) ||
-	    !(ucs->urb_cmd_in = usb_alloc_urb(0, SLAB_KERNEL)) ||
-	    !(ucs->urb_cmd_out = usb_alloc_urb(0, SLAB_KERNEL)) ||
-	    !(ucs->urb_ctrl = usb_alloc_urb(0, SLAB_KERNEL)))
+	if (!(ucs->urb_int_in = usb_alloc_urb(0, GFP_KERNEL)) ||
+	    !(ucs->urb_cmd_in = usb_alloc_urb(0, GFP_KERNEL)) ||
+	    !(ucs->urb_cmd_out = usb_alloc_urb(0, GFP_KERNEL)) ||
+	    !(ucs->urb_ctrl = usb_alloc_urb(0, GFP_KERNEL)))
 		goto allocerr;
 
 	for (j = 0; j < 2; ++j) {
 		ubc = cs->bcs[j].hw.bas;
 		for (i = 0; i < BAS_OUTURBS; ++i)
 			if (!(ubc->isoouturbs[i].urb =
-			      usb_alloc_urb(BAS_NUMFRAMES, SLAB_KERNEL)))
+			      usb_alloc_urb(BAS_NUMFRAMES, GFP_KERNEL)))
 				goto allocerr;
 		for (i = 0; i < BAS_INURBS; ++i)
 			if (!(ubc->isoinurbs[i] =
-			      usb_alloc_urb(BAS_NUMFRAMES, SLAB_KERNEL)))
+			      usb_alloc_urb(BAS_NUMFRAMES, GFP_KERNEL)))
 				goto allocerr;
 	}
 
@@ -2246,7 +2246,7 @@
 					(endpoint->bEndpointAddress) & 0x0f),
 			 ucs->int_in_buf, 3, read_int_callback, cs,
 			 endpoint->bInterval);
-	if ((rc = usb_submit_urb(ucs->urb_int_in, SLAB_KERNEL)) != 0) {
+	if ((rc = usb_submit_urb(ucs->urb_int_in, GFP_KERNEL)) != 0) {
 		dev_err(cs->dev, "could not submit interrupt URB: %s\n",
 			get_usb_rcmsg(rc));
 		goto error;
Index: linux-2.6.19-rc6-mm1/drivers/scsi/ipr.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/ipr.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/ipr.c	2006-11-28 16:11:23.000000000 -0800
@@ -6939,7 +6939,7 @@
 		return -ENOMEM;
 
 	for (i = 0; i < IPR_NUM_CMD_BLKS; i++) {
-		ipr_cmd = pci_pool_alloc (ioa_cfg->ipr_cmd_pool, SLAB_KERNEL, &dma_addr);
+		ipr_cmd = pci_pool_alloc (ioa_cfg->ipr_cmd_pool, GFP_KERNEL, &dma_addr);
 
 		if (!ipr_cmd) {
 			ipr_free_cmd_blks(ioa_cfg);
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_av.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/ehca/ehca_av.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_av.c	2006-11-28 16:11:23.000000000 -0800
@@ -57,7 +57,7 @@
 	struct ehca_shca *shca = container_of(pd->device, struct ehca_shca,
 					      ib_device);
 
-	av = kmem_cache_alloc(av_cache, SLAB_KERNEL);
+	av = kmem_cache_alloc(av_cache, GFP_KERNEL);
 	if (!av) {
 		ehca_err(pd->device, "Out of memory pd=%p ah_attr=%p",
 			 pd, ah_attr);
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_cq.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/ehca/ehca_cq.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_cq.c	2006-11-28 16:11:23.000000000 -0800
@@ -134,7 +134,7 @@
 	if (cqe >= 0xFFFFFFFF - 64 - additional_cqe)
 		return ERR_PTR(-EINVAL);
 
-	my_cq = kmem_cache_alloc(cq_cache, SLAB_KERNEL);
+	my_cq = kmem_cache_alloc(cq_cache, GFP_KERNEL);
 	if (!my_cq) {
 		ehca_err(device, "Out of memory for ehca_cq struct device=%p",
 			 device);
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_pd.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/ehca/ehca_pd.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_pd.c	2006-11-28 16:11:23.000000000 -0800
@@ -50,7 +50,7 @@
 {
 	struct ehca_pd *pd;
 
-	pd = kmem_cache_alloc(pd_cache, SLAB_KERNEL);
+	pd = kmem_cache_alloc(pd_cache, GFP_KERNEL);
 	if (!pd) {
 		ehca_err(device, "device=%p context=%p out of memory",
 			 device, context);
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_qp.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/ehca/ehca_qp.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_qp.c	2006-11-28 16:11:23.000000000 -0800
@@ -450,7 +450,7 @@
 	if (pd->uobject && udata)
 		context = pd->uobject->context;
 
-	my_qp = kmem_cache_alloc(qp_cache, SLAB_KERNEL);
+	my_qp = kmem_cache_alloc(qp_cache, GFP_KERNEL);
 	if (!my_qp) {
 		ehca_err(pd->device, "pd=%p not enough memory to alloc qp", pd);
 		return ERR_PTR(-ENOMEM);
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_main.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/ehca/ehca_main.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_main.c	2006-11-28 16:11:23.000000000 -0800
@@ -108,7 +108,7 @@
 
 void *ehca_alloc_fw_ctrlblock(void)
 {
-	void *ret = kmem_cache_zalloc(ctblk_cache, SLAB_KERNEL);
+	void *ret = kmem_cache_zalloc(ctblk_cache, GFP_KERNEL);
 	if (!ret)
 		ehca_gen_err("Out of memory for ctblk");
 	return ret;
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_mrmw.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/ehca/ehca_mrmw.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/ehca/ehca_mrmw.c	2006-11-28 16:11:23.000000000 -0800
@@ -53,7 +53,7 @@
 {
 	struct ehca_mr *me;
 
-	me = kmem_cache_alloc(mr_cache, SLAB_KERNEL);
+	me = kmem_cache_alloc(mr_cache, GFP_KERNEL);
 	if (me) {
 		memset(me, 0, sizeof(struct ehca_mr));
 		spin_lock_init(&me->mrlock);
@@ -72,7 +72,7 @@
 {
 	struct ehca_mw *me;
 
-	me = kmem_cache_alloc(mw_cache, SLAB_KERNEL);
+	me = kmem_cache_alloc(mw_cache, GFP_KERNEL);
 	if (me) {
 		memset(me, 0, sizeof(struct ehca_mw));
 		spin_lock_init(&me->mwlock);
Index: linux-2.6.19-rc6-mm1/drivers/input/touchscreen/ads7846.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/input/touchscreen/ads7846.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/input/touchscreen/ads7846.c	2006-11-28 16:11:23.000000000 -0800
@@ -190,7 +190,7 @@
 {
 	struct spi_device	*spi = to_spi_device(dev);
 	struct ads7846		*ts = dev_get_drvdata(dev);
-	struct ser_req		*req = kzalloc(sizeof *req, SLAB_KERNEL);
+	struct ser_req		*req = kzalloc(sizeof *req, GFP_KERNEL);
 	int			status;
 	int			sample;
 	int			i;
Index: linux-2.6.19-rc6-mm1/drivers/media/dvb/cinergyT2/cinergyT2.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/media/dvb/cinergyT2/cinergyT2.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/media/dvb/cinergyT2/cinergyT2.c	2006-11-28 16:11:23.000000000 -0800
@@ -286,7 +286,7 @@
 	int i;
 
 	cinergyt2->streambuf = usb_buffer_alloc(cinergyt2->udev, STREAM_URB_COUNT*STREAM_BUF_SIZE,
-					      SLAB_KERNEL, &cinergyt2->streambuf_dmahandle);
+					      GFP_KERNEL, &cinergyt2->streambuf_dmahandle);
 	if (!cinergyt2->streambuf) {
 		dprintk(1, "failed to alloc consistent stream memory area, bailing out!\n");
 		return -ENOMEM;
Index: linux-2.6.19-rc6-mm1/drivers/ieee1394/raw1394.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/ieee1394/raw1394.c	2006-11-28 16:10:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/ieee1394/raw1394.c	2006-11-28 16:11:23.000000000 -0800
@@ -127,7 +127,7 @@
 
 static inline struct pending_request *alloc_pending_request(void)
 {
-	return __alloc_pending_request(SLAB_KERNEL);
+	return __alloc_pending_request(GFP_KERNEL);
 }
 
 static void free_pending_request(struct pending_request *req)
@@ -1752,7 +1752,7 @@
 		return (-EINVAL);
 	}
 	/* addr-list-entry for fileinfo */
-	addr = kmalloc(sizeof(*addr), SLAB_KERNEL);
+	addr = kmalloc(sizeof(*addr), GFP_KERNEL);
 	if (!addr) {
 		req->req.length = 0;
 		return (-ENOMEM);
@@ -2118,7 +2118,7 @@
 static int get_config_rom(struct file_info *fi, struct pending_request *req)
 {
 	int ret = sizeof(struct raw1394_request);
-	quadlet_t *data = kmalloc(req->req.length, SLAB_KERNEL);
+	quadlet_t *data = kmalloc(req->req.length, GFP_KERNEL);
 	int status;
 
 	if (!data)
@@ -2148,7 +2148,7 @@
 static int update_config_rom(struct file_info *fi, struct pending_request *req)
 {
 	int ret = sizeof(struct raw1394_request);
-	quadlet_t *data = kmalloc(req->req.length, SLAB_KERNEL);
+	quadlet_t *data = kmalloc(req->req.length, GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 	if (copy_from_user(data, int2ptr(req->req.sendb), req->req.length)) {
@@ -2796,7 +2796,7 @@
 {
 	struct file_info *fi;
 
-	fi = kzalloc(sizeof(*fi), SLAB_KERNEL);
+	fi = kzalloc(sizeof(*fi), GFP_KERNEL);
 	if (!fi)
 		return -ENOMEM;
 
Index: linux-2.6.19-rc6-mm1/drivers/ieee1394/ohci1394.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/ieee1394/ohci1394.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/ieee1394/ohci1394.c	2006-11-28 16:11:23.000000000 -0800
@@ -1223,7 +1223,7 @@
 	int ctx;
 	int ret = -ENOMEM;
 
-	recv = kmalloc(sizeof(*recv), SLAB_KERNEL);
+	recv = kmalloc(sizeof(*recv), GFP_KERNEL);
 	if (!recv)
 		return -ENOMEM;
 
@@ -1916,7 +1916,7 @@
 	int ctx;
 	int ret = -ENOMEM;
 
-	xmit = kmalloc(sizeof(*xmit), SLAB_KERNEL);
+	xmit = kmalloc(sizeof(*xmit), GFP_KERNEL);
 	if (!xmit)
 		return -ENOMEM;
 
@@ -3019,7 +3019,7 @@
 			return -ENOMEM;
 		}
 
-		d->prg_cpu[i] = pci_pool_alloc(d->prg_pool, SLAB_KERNEL, d->prg_bus+i);
+		d->prg_cpu[i] = pci_pool_alloc(d->prg_pool, GFP_KERNEL, d->prg_bus+i);
 		OHCI_DMA_ALLOC("pool dma_rcv prg[%d]", i);
 
                 if (d->prg_cpu[i] != NULL) {
@@ -3115,7 +3115,7 @@
 	OHCI_DMA_ALLOC("dma_rcv prg pool");
 
 	for (i = 0; i < d->num_desc; i++) {
-		d->prg_cpu[i] = pci_pool_alloc(d->prg_pool, SLAB_KERNEL, d->prg_bus+i);
+		d->prg_cpu[i] = pci_pool_alloc(d->prg_pool, GFP_KERNEL, d->prg_bus+i);
 		OHCI_DMA_ALLOC("pool dma_trm prg[%d]", i);
 
                 if (d->prg_cpu[i] != NULL) {
Index: linux-2.6.19-rc6-mm1/drivers/ieee1394/hosts.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/ieee1394/hosts.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/ieee1394/hosts.c	2006-11-28 16:11:23.000000000 -0800
@@ -125,7 +125,7 @@
 	int i;
 	int hostnum = 0;
 
-	h = kzalloc(sizeof(*h) + extra, SLAB_KERNEL);
+	h = kzalloc(sizeof(*h) + extra, GFP_KERNEL);
 	if (!h)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/drivers/ieee1394/pcilynx.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/ieee1394/pcilynx.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/ieee1394/pcilynx.c	2006-11-28 16:11:23.000000000 -0800
@@ -1428,7 +1428,7 @@
         	struct i2c_algo_bit_data i2c_adapter_data;
 
         	error = -ENOMEM;
-		i2c_ad = kmemdup(&bit_ops, sizeof(*i2c_ad), SLAB_KERNEL);
+		i2c_ad = kmemdup(&bit_ops, sizeof(*i2c_ad), GFP_KERNEL);
         	if (!i2c_ad) FAIL("failed to allocate I2C adapter memory");
 
                 i2c_adapter_data = bit_data;
Index: linux-2.6.19-rc6-mm1/fs/afs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/afs/super.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/afs/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -412,7 +412,7 @@
 	struct afs_vnode *vnode;
 
 	vnode = (struct afs_vnode *)
-		kmem_cache_alloc(afs_inode_cachep, SLAB_KERNEL);
+		kmem_cache_alloc(afs_inode_cachep, GFP_KERNEL);
 	if (!vnode)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/fs/bfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/bfs/inode.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/bfs/inode.c	2006-11-28 16:11:23.000000000 -0800
@@ -233,7 +233,7 @@
 static struct inode *bfs_alloc_inode(struct super_block *sb)
 {
 	struct bfs_inode_info *bi;
-	bi = kmem_cache_alloc(bfs_inode_cachep, SLAB_KERNEL);
+	bi = kmem_cache_alloc(bfs_inode_cachep, GFP_KERNEL);
 	if (!bi)
 		return NULL;
 	return &bi->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/efs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/efs/super.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/efs/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -57,7 +57,7 @@
 static struct inode *efs_alloc_inode(struct super_block *sb)
 {
 	struct efs_inode_info *ei;
-	ei = (struct efs_inode_info *)kmem_cache_alloc(efs_inode_cachep, SLAB_KERNEL);
+	ei = (struct efs_inode_info *)kmem_cache_alloc(efs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/fat/cache.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fat/cache.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fat/cache.c	2006-11-28 16:11:23.000000000 -0800
@@ -63,7 +63,7 @@
 
 static inline struct fat_cache *fat_cache_alloc(struct inode *inode)
 {
-	return kmem_cache_alloc(fat_cache_cachep, SLAB_KERNEL);
+	return kmem_cache_alloc(fat_cache_cachep, GFP_KERNEL);
 }
 
 static inline void fat_cache_free(struct fat_cache *cache)
Index: linux-2.6.19-rc6-mm1/fs/fat/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fat/inode.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fat/inode.c	2006-11-28 16:11:23.000000000 -0800
@@ -482,7 +482,7 @@
 static struct inode *fat_alloc_inode(struct super_block *sb)
 {
 	struct msdos_inode_info *ei;
-	ei = kmem_cache_alloc(fat_inode_cachep, SLAB_KERNEL);
+	ei = kmem_cache_alloc(fat_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/hfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hfs/super.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hfs/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -145,7 +145,7 @@
 {
 	struct hfs_inode_info *i;
 
-	i = kmem_cache_alloc(hfs_inode_cachep, SLAB_KERNEL);
+	i = kmem_cache_alloc(hfs_inode_cachep, GFP_KERNEL);
 	return i ? &i->vfs_inode : NULL;
 }
 
Index: linux-2.6.19-rc6-mm1/fs/nfs/direct.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/direct.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/direct.c	2006-11-28 16:11:23.000000000 -0800
@@ -143,7 +143,7 @@
 {
 	struct nfs_direct_req *dreq;
 
-	dreq = kmem_cache_alloc(nfs_direct_cachep, SLAB_KERNEL);
+	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_KERNEL);
 	if (!dreq)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/pagelist.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/pagelist.c	2006-11-28 16:11:23.000000000 -0800
@@ -25,7 +25,7 @@
 nfs_page_alloc(void)
 {
 	struct nfs_page	*p;
-	p = kmem_cache_alloc(nfs_page_cachep, SLAB_KERNEL);
+	p = kmem_cache_alloc(nfs_page_cachep, GFP_KERNEL);
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->wb_list);
Index: linux-2.6.19-rc6-mm1/fs/nfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/inode.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/inode.c	2006-11-28 16:11:23.000000000 -0800
@@ -1070,7 +1070,7 @@
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
-	nfsi = (struct nfs_inode *)kmem_cache_alloc(nfs_inode_cachep, SLAB_KERNEL);
+	nfsi = (struct nfs_inode *)kmem_cache_alloc(nfs_inode_cachep, GFP_KERNEL);
 	if (!nfsi)
 		return NULL;
 	nfsi->flags = 0UL;
Index: linux-2.6.19-rc6-mm1/fs/udf/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/udf/super.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/udf/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -112,7 +112,7 @@
 static struct inode *udf_alloc_inode(struct super_block *sb)
 {
 	struct udf_inode_info *ei;
-	ei = (struct udf_inode_info *)kmem_cache_alloc(udf_inode_cachep, SLAB_KERNEL);
+	ei = (struct udf_inode_info *)kmem_cache_alloc(udf_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/fs/ufs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ufs/super.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ufs/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -1209,7 +1209,7 @@
 static struct inode *ufs_alloc_inode(struct super_block *sb)
 {
 	struct ufs_inode_info *ei;
-	ei = (struct ufs_inode_info *)kmem_cache_alloc(ufs_inode_cachep, SLAB_KERNEL);
+	ei = (struct ufs_inode_info *)kmem_cache_alloc(ufs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	ei->vfs_inode.i_version = 1;
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/crypto.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/crypto.c	2006-11-28 16:08:59.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/crypto.c	2006-11-28 16:11:23.000000000 -0800
@@ -628,7 +628,7 @@
 	num_extents_per_page = PAGE_CACHE_SIZE / crypt_stat->extent_size;
 	base_extent = (page->index * num_extents_per_page);
 	lower_page_virt = kmem_cache_alloc(ecryptfs_lower_page_cache,
-					   SLAB_KERNEL);
+					   GFP_KERNEL);
 	if (!lower_page_virt) {
 		rc = -ENOMEM;
 		ecryptfs_printk(KERN_ERR, "Error getting page for encrypted "
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/keystore.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/keystore.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/keystore.c	2006-11-28 16:11:23.000000000 -0800
@@ -207,7 +207,7 @@
 	/* Released: wipe_auth_tok_list called in ecryptfs_parse_packet_set or
 	 * at end of function upon failure */
 	auth_tok_list_item =
-	    kmem_cache_alloc(ecryptfs_auth_tok_list_item_cache, SLAB_KERNEL);
+	    kmem_cache_alloc(ecryptfs_auth_tok_list_item_cache, GFP_KERNEL);
 	if (!auth_tok_list_item) {
 		ecryptfs_printk(KERN_ERR, "Unable to allocate memory\n");
 		rc = -ENOMEM;
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/super.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -50,7 +50,7 @@
 	struct inode *inode = NULL;
 
 	ecryptfs_inode = kmem_cache_alloc(ecryptfs_inode_info_cache,
-					  SLAB_KERNEL);
+					  GFP_KERNEL);
 	if (unlikely(!ecryptfs_inode))
 		goto out;
 	ecryptfs_init_crypt_stat(&ecryptfs_inode->crypt_stat);
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/file.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/file.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/file.c	2006-11-28 16:11:23.000000000 -0800
@@ -251,7 +251,7 @@
 	int lower_flags;
 
 	/* Released in ecryptfs_release or end of function if failure */
-	file_info = kmem_cache_alloc(ecryptfs_file_info_cache, SLAB_KERNEL);
+	file_info = kmem_cache_alloc(ecryptfs_file_info_cache, GFP_KERNEL);
 	ecryptfs_set_file_private(file, file_info);
 	if (!file_info) {
 		ecryptfs_printk(KERN_ERR,
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/main.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/main.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/main.c	2006-11-28 16:11:23.000000000 -0800
@@ -379,7 +379,7 @@
 	/* Released in ecryptfs_put_super() */
 	ecryptfs_set_superblock_private(sb,
 					kmem_cache_alloc(ecryptfs_sb_info_cache,
-							 SLAB_KERNEL));
+							 GFP_KERNEL));
 	if (!ecryptfs_superblock_to_private(sb)) {
 		ecryptfs_printk(KERN_WARNING, "Out of memory\n");
 		rc = -ENOMEM;
@@ -403,7 +403,7 @@
 	/* through deactivate_super(sb) from get_sb_nodev() */
 	ecryptfs_set_dentry_private(sb->s_root,
 				    kmem_cache_alloc(ecryptfs_dentry_info_cache,
-						     SLAB_KERNEL));
+						     GFP_KERNEL));
 	if (!ecryptfs_dentry_to_private(sb->s_root)) {
 		ecryptfs_printk(KERN_ERR,
 				"dentry_info_cache alloc failed\n");
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/inode.c	2006-11-28 16:08:59.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/inode.c	2006-11-28 16:11:23.000000000 -0800
@@ -328,7 +328,7 @@
 	BUG_ON(!atomic_read(&lower_dentry->d_count));
 	ecryptfs_set_dentry_private(dentry,
 				    kmem_cache_alloc(ecryptfs_dentry_info_cache,
-						     SLAB_KERNEL));
+						     GFP_KERNEL));
 	if (!ecryptfs_dentry_to_private(dentry)) {
 		rc = -ENOMEM;
 		ecryptfs_printk(KERN_ERR, "Out of memory whilst attempting "
@@ -758,7 +758,7 @@
 	/* Released at out_free: label */
 	ecryptfs_set_file_private(&fake_ecryptfs_file,
 				  kmem_cache_alloc(ecryptfs_file_info_cache,
-						   SLAB_KERNEL));
+						   GFP_KERNEL));
 	if (unlikely(!ecryptfs_file_to_private(&fake_ecryptfs_file))) {
 		rc = -ENOMEM;
 		goto out;
Index: linux-2.6.19-rc6-mm1/fs/adfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/adfs/super.c	2006-11-28 16:02:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/adfs/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -217,7 +217,7 @@
 static struct inode *adfs_alloc_inode(struct super_block *sb)
 {
 	struct adfs_inode_info *ei;
-	ei = (struct adfs_inode_info *)kmem_cache_alloc(adfs_inode_cachep, SLAB_KERNEL);
+	ei = (struct adfs_inode_info *)kmem_cache_alloc(adfs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/affs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/affs/super.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/affs/super.c	2006-11-28 16:11:23.000000000 -0800
@@ -71,7 +71,7 @@
 static struct inode *affs_alloc_inode(struct super_block *sb)
 {
 	struct affs_inode_info *ei;
-	ei = (struct affs_inode_info *)kmem_cache_alloc(affs_inode_cachep, SLAB_KERNEL);
+	ei = (struct affs_inode_info *)kmem_cache_alloc(affs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	ei->vfs_inode.i_version = 1;
Index: linux-2.6.19-rc6-mm1/fs/befs/linuxvfs.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/befs/linuxvfs.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/befs/linuxvfs.c	2006-11-28 16:11:23.000000000 -0800
@@ -277,7 +277,7 @@
 {
         struct befs_inode_info *bi;
         bi = (struct befs_inode_info *)kmem_cache_alloc(befs_inode_cachep,
-							SLAB_KERNEL);
+							GFP_KERNEL);
         if (!bi)
                 return NULL;
         return &bi->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/cifs/cifsfs.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/cifs/cifsfs.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/cifs/cifsfs.c	2006-11-28 16:11:23.000000000 -0800
@@ -246,7 +246,7 @@
 cifs_alloc_inode(struct super_block *sb)
 {
 	struct cifsInodeInfo *cifs_inode;
-	cifs_inode = kmem_cache_alloc(cifs_inode_cachep, SLAB_KERNEL);
+	cifs_inode = kmem_cache_alloc(cifs_inode_cachep, GFP_KERNEL);
 	if (!cifs_inode)
 		return NULL;
 	cifs_inode->cifsAttrs = 0x20;	/* default */
Index: linux-2.6.19-rc6-mm1/fs/cifs/misc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/cifs/misc.c	2006-11-28 16:08:36.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/cifs/misc.c	2006-11-28 16:11:23.000000000 -0800
@@ -153,7 +153,7 @@
    albeit slightly larger than necessary and maxbuffersize 
    defaults to this and can not be bigger */
 	ret_buf =
-	    (struct smb_hdr *) mempool_alloc(cifs_req_poolp, SLAB_KERNEL | GFP_NOFS);
+	    (struct smb_hdr *) mempool_alloc(cifs_req_poolp, GFP_KERNEL | GFP_NOFS);
 
 	/* clear the first few header bytes */
 	/* for most paths, more is cleared in header_assemble */
@@ -192,7 +192,7 @@
    albeit slightly larger than necessary and maxbuffersize 
    defaults to this and can not be bigger */
 	ret_buf =
-	    (struct smb_hdr *) mempool_alloc(cifs_sm_req_poolp, SLAB_KERNEL | GFP_NOFS);
+	    (struct smb_hdr *) mempool_alloc(cifs_sm_req_poolp, GFP_KERNEL | GFP_NOFS);
 	if (ret_buf) {
 	/* No need to clear memory here, cleared in header assemble */
 	/*	memset(ret_buf, 0, sizeof(struct smb_hdr) + 27);*/
Index: linux-2.6.19-rc6-mm1/fs/cifs/transport.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/cifs/transport.c	2006-11-28 16:08:36.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/cifs/transport.c	2006-11-28 16:11:24.000000000 -0800
@@ -51,7 +51,7 @@
 	}
 	
 	temp = (struct mid_q_entry *) mempool_alloc(cifs_mid_poolp,
-						    SLAB_KERNEL | GFP_NOFS);
+						    GFP_KERNEL | GFP_NOFS);
 	if (temp == NULL)
 		return temp;
 	else {
@@ -118,7 +118,7 @@
 		return NULL;
 	}
 	temp = (struct oplock_q_entry *) kmem_cache_alloc(cifs_oplock_cachep,
-						       SLAB_KERNEL);
+						       GFP_KERNEL);
 	if (temp == NULL)
 		return temp;
 	else {
Index: linux-2.6.19-rc6-mm1/fs/coda/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/coda/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/coda/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -43,7 +43,7 @@
 static struct inode *coda_alloc_inode(struct super_block *sb)
 {
 	struct coda_inode_info *ei;
-	ei = (struct coda_inode_info *)kmem_cache_alloc(coda_inode_cachep, SLAB_KERNEL);
+	ei = (struct coda_inode_info *)kmem_cache_alloc(coda_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	memset(&ei->c_fid, 0, sizeof(struct CodaFid));
Index: linux-2.6.19-rc6-mm1/fs/ext2/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ext2/super.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ext2/super.c	2006-11-28 16:11:24.000000000 -0800
@@ -140,7 +140,7 @@
 static struct inode *ext2_alloc_inode(struct super_block *sb)
 {
 	struct ext2_inode_info *ei;
-	ei = (struct ext2_inode_info *)kmem_cache_alloc(ext2_inode_cachep, SLAB_KERNEL);
+	ei = (struct ext2_inode_info *)kmem_cache_alloc(ext2_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT2_FS_POSIX_ACL
Index: linux-2.6.19-rc6-mm1/fs/fuse/dev.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fuse/dev.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fuse/dev.c	2006-11-28 16:11:24.000000000 -0800
@@ -41,7 +41,7 @@
 
 struct fuse_req *fuse_request_alloc(void)
 {
-	struct fuse_req *req = kmem_cache_alloc(fuse_req_cachep, SLAB_KERNEL);
+	struct fuse_req *req = kmem_cache_alloc(fuse_req_cachep, GFP_KERNEL);
 	if (req)
 		fuse_request_init(req);
 	return req;
Index: linux-2.6.19-rc6-mm1/fs/fuse/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fuse/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fuse/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -47,7 +47,7 @@
 	struct inode *inode;
 	struct fuse_inode *fi;
 
-	inode = kmem_cache_alloc(fuse_inode_cachep, SLAB_KERNEL);
+	inode = kmem_cache_alloc(fuse_inode_cachep, GFP_KERNEL);
 	if (!inode)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/fs/proc/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/proc/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/proc/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -88,7 +88,7 @@
 	struct proc_inode *ei;
 	struct inode *inode;
 
-	ei = (struct proc_inode *)kmem_cache_alloc(proc_inode_cachep, SLAB_KERNEL);
+	ei = (struct proc_inode *)kmem_cache_alloc(proc_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	ei->pid = NULL;
Index: linux-2.6.19-rc6-mm1/fs/qnx4/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/qnx4/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/qnx4/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -520,7 +520,7 @@
 static struct inode *qnx4_alloc_inode(struct super_block *sb)
 {
 	struct qnx4_inode_info *ei;
-	ei = kmem_cache_alloc(qnx4_inode_cachep, SLAB_KERNEL);
+	ei = kmem_cache_alloc(qnx4_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/sysv/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/sysv/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/sysv/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -307,7 +307,7 @@
 {
 	struct sysv_inode_info *si;
 
-	si = kmem_cache_alloc(sysv_inode_cachep, SLAB_KERNEL);
+	si = kmem_cache_alloc(sysv_inode_cachep, GFP_KERNEL);
 	if (!si)
 		return NULL;
 	return &si->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/reiserfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiserfs/super.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiserfs/super.c	2006-11-28 16:11:24.000000000 -0800
@@ -496,7 +496,7 @@
 {
 	struct reiserfs_inode_info *ei;
 	ei = (struct reiserfs_inode_info *)
-	    kmem_cache_alloc(reiserfs_inode_cachep, SLAB_KERNEL);
+	    kmem_cache_alloc(reiserfs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/block_dev.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/block_dev.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/block_dev.c	2006-11-28 16:11:24.000000000 -0800
@@ -241,7 +241,7 @@
 
 static struct inode *bdev_alloc_inode(struct super_block *sb)
 {
-	struct bdev_inode *ei = kmem_cache_alloc(bdev_cachep, SLAB_KERNEL);
+	struct bdev_inode *ei = kmem_cache_alloc(bdev_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/jffs2/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jffs2/super.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jffs2/super.c	2006-11-28 16:11:24.000000000 -0800
@@ -33,7 +33,7 @@
 static struct inode *jffs2_alloc_inode(struct super_block *sb)
 {
 	struct jffs2_inode_info *ei;
-	ei = (struct jffs2_inode_info *)kmem_cache_alloc(jffs2_inode_cachep, SLAB_KERNEL);
+	ei = (struct jffs2_inode_info *)kmem_cache_alloc(jffs2_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/isofs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/isofs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/isofs/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -62,7 +62,7 @@
 static struct inode *isofs_alloc_inode(struct super_block *sb)
 {
 	struct iso_inode_info *ei;
-	ei = kmem_cache_alloc(isofs_inode_cachep, SLAB_KERNEL);
+	ei = kmem_cache_alloc(isofs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/minix/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/minix/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/minix/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -56,7 +56,7 @@
 static struct inode *minix_alloc_inode(struct super_block *sb)
 {
 	struct minix_inode_info *ei;
-	ei = (struct minix_inode_info *)kmem_cache_alloc(minix_inode_cachep, SLAB_KERNEL);
+	ei = (struct minix_inode_info *)kmem_cache_alloc(minix_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/ncpfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ncpfs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ncpfs/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -45,7 +45,7 @@
 static struct inode *ncp_alloc_inode(struct super_block *sb)
 {
 	struct ncp_inode_info *ei;
-	ei = (struct ncp_inode_info *)kmem_cache_alloc(ncp_inode_cachep, SLAB_KERNEL);
+	ei = (struct ncp_inode_info *)kmem_cache_alloc(ncp_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/romfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/romfs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/romfs/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -555,7 +555,7 @@
 static struct inode *romfs_alloc_inode(struct super_block *sb)
 {
 	struct romfs_inode_info *ei;
-	ei = (struct romfs_inode_info *)kmem_cache_alloc(romfs_inode_cachep, SLAB_KERNEL);
+	ei = (struct romfs_inode_info *)kmem_cache_alloc(romfs_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/smbfs/request.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/smbfs/request.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/smbfs/request.c	2006-11-28 16:11:24.000000000 -0800
@@ -61,7 +61,7 @@
 	struct smb_request *req;
 	unsigned char *buf = NULL;
 
-	req = kmem_cache_alloc(req_cachep, SLAB_KERNEL);
+	req = kmem_cache_alloc(req_cachep, GFP_KERNEL);
 	VERBOSE("allocating request: %p\n", req);
 	if (!req)
 		goto out;
Index: linux-2.6.19-rc6-mm1/fs/smbfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/smbfs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/smbfs/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -55,7 +55,7 @@
 static struct inode *smb_alloc_inode(struct super_block *sb)
 {
 	struct smb_inode_info *ei;
-	ei = (struct smb_inode_info *)kmem_cache_alloc(smb_inode_cachep, SLAB_KERNEL);
+	ei = (struct smb_inode_info *)kmem_cache_alloc(smb_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/fs/fcntl.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fcntl.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fcntl.c	2006-11-28 16:11:24.000000000 -0800
@@ -566,7 +566,7 @@
 	int result = 0;
 
 	if (on) {
-		new = kmem_cache_alloc(fasync_cache, SLAB_KERNEL);
+		new = kmem_cache_alloc(fasync_cache, GFP_KERNEL);
 		if (!new)
 			return -ENOMEM;
 	}
Index: linux-2.6.19-rc6-mm1/fs/locks.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/locks.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/locks.c	2006-11-28 16:11:24.000000000 -0800
@@ -147,7 +147,7 @@
 /* Allocate an empty lock structure. */
 static struct file_lock *locks_alloc_lock(void)
 {
-	return kmem_cache_alloc(filelock_cache, SLAB_KERNEL);
+	return kmem_cache_alloc(filelock_cache, GFP_KERNEL);
 }
 
 static void locks_release_private(struct file_lock *fl)
Index: linux-2.6.19-rc6-mm1/fs/eventpoll.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/eventpoll.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/eventpoll.c	2006-11-28 16:11:24.000000000 -0800
@@ -961,7 +961,7 @@
 	struct epitem *epi = ep_item_from_epqueue(pt);
 	struct eppoll_entry *pwq;
 
-	if (epi->nwait >= 0 && (pwq = kmem_cache_alloc(pwq_cache, SLAB_KERNEL))) {
+	if (epi->nwait >= 0 && (pwq = kmem_cache_alloc(pwq_cache, GFP_KERNEL))) {
 		init_waitqueue_func_entry(&pwq->wait, ep_poll_callback);
 		pwq->whead = whead;
 		pwq->base = epi;
@@ -1004,7 +1004,7 @@
 	struct ep_pqueue epq;
 
 	error = -ENOMEM;
-	if (!(epi = kmem_cache_alloc(epi_cache, SLAB_KERNEL)))
+	if (!(epi = kmem_cache_alloc(epi_cache, GFP_KERNEL)))
 		goto eexit_1;
 
 	/* Item initialization follow here ... */
Index: linux-2.6.19-rc6-mm1/fs/exec.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/exec.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/exec.c	2006-11-28 16:11:24.000000000 -0800
@@ -405,7 +405,7 @@
 		bprm->loader += stack_base;
 	bprm->exec += stack_base;
 
-	mpnt = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	mpnt = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!mpnt)
 		return -ENOMEM;
 
Index: linux-2.6.19-rc6-mm1/fs/dnotify.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dnotify.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dnotify.c	2006-11-28 16:11:24.000000000 -0800
@@ -77,7 +77,7 @@
 	inode = filp->f_path.dentry->d_inode;
 	if (!S_ISDIR(inode->i_mode))
 		return -ENOTDIR;
-	dn = kmem_cache_alloc(dn_cache, SLAB_KERNEL);
+	dn = kmem_cache_alloc(dn_cache, GFP_KERNEL);
 	if (dn == NULL)
 		return -ENOMEM;
 	spin_lock(&inode->i_lock);
Index: linux-2.6.19-rc6-mm1/fs/freevxfs/vxfs_inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/freevxfs/vxfs_inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/freevxfs/vxfs_inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -103,7 +103,7 @@
 		struct vxfs_inode_info	*vip;
 		struct vxfs_dinode	*dip;
 
-		if (!(vip = kmem_cache_alloc(vxfs_inode_cachep, SLAB_KERNEL)))
+		if (!(vip = kmem_cache_alloc(vxfs_inode_cachep, GFP_KERNEL)))
 			goto fail;
 		dip = (struct vxfs_dinode *)(bp->b_data + offset);
 		memcpy(vip, dip, sizeof(*vip));
@@ -145,7 +145,7 @@
 		struct vxfs_dinode	*dip;
 		caddr_t			kaddr = (char *)page_address(pp);
 
-		if (!(vip = kmem_cache_alloc(vxfs_inode_cachep, SLAB_KERNEL)))
+		if (!(vip = kmem_cache_alloc(vxfs_inode_cachep, GFP_KERNEL)))
 			goto fail;
 		dip = (struct vxfs_dinode *)(kaddr + offset);
 		memcpy(vip, dip, sizeof(*vip));
Index: linux-2.6.19-rc6-mm1/fs/hfsplus/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hfsplus/super.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hfsplus/super.c	2006-11-28 16:11:24.000000000 -0800
@@ -440,7 +440,7 @@
 {
 	struct hfsplus_inode_info *i;
 
-	i = kmem_cache_alloc(hfsplus_inode_cachep, SLAB_KERNEL);
+	i = kmem_cache_alloc(hfsplus_inode_cachep, GFP_KERNEL);
 	return i ? &i->vfs_inode : NULL;
 }
 
Index: linux-2.6.19-rc6-mm1/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hugetlbfs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hugetlbfs/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -522,7 +522,7 @@
 
 	if (unlikely(!hugetlbfs_dec_free_inodes(sbinfo)))
 		return NULL;
-	p = kmem_cache_alloc(hugetlbfs_inode_cachep, SLAB_KERNEL);
+	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL);
 	if (unlikely(!p)) {
 		hugetlbfs_inc_free_inodes(sbinfo);
 		return NULL;
Index: linux-2.6.19-rc6-mm1/fs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -110,7 +110,7 @@
 	if (sb->s_op->alloc_inode)
 		inode = sb->s_op->alloc_inode(sb);
 	else
-		inode = (struct inode *) kmem_cache_alloc(inode_cachep, SLAB_KERNEL);
+		inode = (struct inode *) kmem_cache_alloc(inode_cachep, GFP_KERNEL);
 
 	if (inode) {
 		struct address_space * const mapping = &inode->i_data;
Index: linux-2.6.19-rc6-mm1/fs/openpromfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/openpromfs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/openpromfs/inode.c	2006-11-28 16:11:24.000000000 -0800
@@ -336,7 +336,7 @@
 {
 	struct op_inode_info *oi;
 
-	oi = kmem_cache_alloc(op_inode_cachep, SLAB_KERNEL);
+	oi = kmem_cache_alloc(op_inode_cachep, GFP_KERNEL);
 	if (!oi)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/include/linux/fs.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/fs.h	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/fs.h	2006-11-28 16:11:24.000000000 -0800
@@ -1543,7 +1543,7 @@
 
 extern struct kmem_cache *names_cachep;
 
-#define __getname()	kmem_cache_alloc(names_cachep, SLAB_KERNEL)
+#define __getname()	kmem_cache_alloc(names_cachep, GFP_KERNEL)
 #define __putname(name) kmem_cache_free(names_cachep, (void *)(name))
 #ifndef CONFIG_AUDITSYSCALL
 #define putname(name)   __putname(name)
Index: linux-2.6.19-rc6-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/rmap.h	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/rmap.h	2006-11-28 16:11:24.000000000 -0800
@@ -34,7 +34,7 @@
 
 static inline struct anon_vma *anon_vma_alloc(void)
 {
-	return kmem_cache_alloc(anon_vma_cachep, SLAB_KERNEL);
+	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 }
 
 static inline void anon_vma_free(struct anon_vma *anon_vma)
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 16:10:10.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 16:11:39.000000000 -0800
@@ -17,7 +17,6 @@
 #include	<linux/types.h>
 
 /* flags for kmem_cache_alloc() */
-#define	SLAB_KERNEL		GFP_KERNEL
 #define	SLAB_DMA		GFP_DMA
 
 /* flags to pass to kmem_cache_create().
Index: linux-2.6.19-rc6-mm1/ipc/mqueue.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/ipc/mqueue.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/ipc/mqueue.c	2006-11-28 16:11:24.000000000 -0800
@@ -224,7 +224,7 @@
 {
 	struct mqueue_inode_info *ei;
 
-	ei = kmem_cache_alloc(mqueue_inode_cachep, SLAB_KERNEL);
+	ei = kmem_cache_alloc(mqueue_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
Index: linux-2.6.19-rc6-mm1/kernel/delayacct.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/delayacct.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/delayacct.c	2006-11-28 16:11:24.000000000 -0800
@@ -41,7 +41,7 @@
 
 void __delayacct_tsk_init(struct task_struct *tsk)
 {
-	tsk->delays = kmem_cache_zalloc(delayacct_cache, SLAB_KERNEL);
+	tsk->delays = kmem_cache_zalloc(delayacct_cache, GFP_KERNEL);
 	if (tsk->delays)
 		spin_lock_init(&tsk->delays->lock);
 }
Index: linux-2.6.19-rc6-mm1/kernel/taskstats.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/taskstats.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/taskstats.c	2006-11-28 16:11:24.000000000 -0800
@@ -436,7 +436,7 @@
 		goto ret;
 
 	/* No problem if kmem_cache_zalloc() fails */
-	stats = kmem_cache_zalloc(taskstats_cache, SLAB_KERNEL);
+	stats = kmem_cache_zalloc(taskstats_cache, GFP_KERNEL);
 
 	spin_lock_irq(&tsk->sighand->siglock);
 	if (!sig->stats) {
Index: linux-2.6.19-rc6-mm1/kernel/fork.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/fork.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/fork.c	2006-11-28 16:11:24.000000000 -0800
@@ -238,7 +238,7 @@
 				goto fail_nomem;
 			charge = len;
 		}
-		tmp = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
@@ -320,7 +320,7 @@
 
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
 
-#define allocate_mm()	(kmem_cache_alloc(mm_cachep, SLAB_KERNEL))
+#define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
 #define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
 
 #include <linux/init_task.h>
@@ -631,7 +631,7 @@
 	struct files_struct *newf;
 	struct fdtable *fdt;
 
-	newf = kmem_cache_alloc(files_cachep, SLAB_KERNEL);
+	newf = kmem_cache_alloc(files_cachep, GFP_KERNEL);
 	if (!newf)
 		goto out;
 
Index: linux-2.6.19-rc6-mm1/kernel/kevent/kevent_poll.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/kevent/kevent_poll.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/kevent/kevent_poll.c	2006-11-28 16:11:24.000000000 -0800
@@ -76,7 +76,7 @@
 	struct kevent_poll_wait_container *cont;
 	unsigned long flags;
 
-	cont = kmem_cache_alloc(kevent_poll_container_cache, SLAB_KERNEL);
+	cont = kmem_cache_alloc(kevent_poll_container_cache, GFP_KERNEL);
 	if (!cont) {
 		kevent_break(k);
 		return;
@@ -110,7 +110,7 @@
 		goto err_out_fput;
 
 	err = -ENOMEM;
-	priv = kmem_cache_alloc(kevent_poll_priv_cache, SLAB_KERNEL);
+	priv = kmem_cache_alloc(kevent_poll_priv_cache, GFP_KERNEL);
 	if (!priv)
 		goto err_out_fput;
 
Index: linux-2.6.19-rc6-mm1/kernel/user.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/user.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/user.c	2006-11-28 16:11:24.000000000 -0800
@@ -132,7 +132,7 @@
 	if (!up) {
 		struct user_struct *new;
 
-		new = kmem_cache_alloc(uid_cachep, SLAB_KERNEL);
+		new = kmem_cache_alloc(uid_cachep, GFP_KERNEL);
 		if (!new)
 			return NULL;
 		new->uid = uid;
Index: linux-2.6.19-rc6-mm1/mm/shmem.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/shmem.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/mm/shmem.c	2006-11-28 16:11:24.000000000 -0800
@@ -2263,7 +2263,7 @@
 static struct inode *shmem_alloc_inode(struct super_block *sb)
 {
 	struct shmem_inode_info *p;
-	p = (struct shmem_inode_info *)kmem_cache_alloc(shmem_inode_cachep, SLAB_KERNEL);
+	p = (struct shmem_inode_info *)kmem_cache_alloc(shmem_inode_cachep, GFP_KERNEL);
 	if (!p)
 		return NULL;
 	return &p->vfs_inode;
Index: linux-2.6.19-rc6-mm1/mm/mmap.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/mmap.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/mm/mmap.c	2006-11-28 16:11:24.000000000 -0800
@@ -1736,7 +1736,7 @@
 	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
 
-	new = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
 
@@ -2057,7 +2057,7 @@
 		    vma_start < new_vma->vm_end)
 			*vmap = new_vma;
 	} else {
-		new_vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (new_vma) {
 			*new_vma = *vma;
 			pol = mpol_copy(vma_policy(vma));
Index: linux-2.6.19-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/slab.c	2006-11-28 16:06:58.000000000 -0800
+++ linux-2.6.19-rc6-mm1/mm/slab.c	2006-11-28 16:11:24.000000000 -0800
@@ -2239,7 +2239,7 @@
 	align = ralign;
 
 	/* Get cache's description obj. */
-	cachep = kmem_cache_zalloc(&cache_cache, SLAB_KERNEL);
+	cachep = kmem_cache_zalloc(&cache_cache, GFP_KERNEL);
 	if (!cachep)
 		goto oops;
 
Index: linux-2.6.19-rc6-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/mempolicy.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/mm/mempolicy.c	2006-11-28 16:11:24.000000000 -0800
@@ -1326,7 +1326,7 @@
 	atomic_set(&new->refcnt, 1);
 	if (new->policy == MPOL_BIND) {
 		int sz = ksize(old->v.zonelist);
-		new->v.zonelist = kmemdup(old->v.zonelist, sz, SLAB_KERNEL);
+		new->v.zonelist = kmemdup(old->v.zonelist, sz, GFP_KERNEL);
 		if (!new->v.zonelist) {
 			kmem_cache_free(policy_cache, new);
 			return ERR_PTR(-ENOMEM);
Index: linux-2.6.19-rc6-mm1/net/ipv4/fib_hash.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/fib_hash.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/fib_hash.c	2006-11-28 16:11:24.000000000 -0800
@@ -485,13 +485,13 @@
 		goto out;
 
 	err = -ENOBUFS;
-	new_fa = kmem_cache_alloc(fn_alias_kmem, SLAB_KERNEL);
+	new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
 	if (new_fa == NULL)
 		goto out;
 
 	new_f = NULL;
 	if (!f) {
-		new_f = kmem_cache_alloc(fn_hash_kmem, SLAB_KERNEL);
+		new_f = kmem_cache_alloc(fn_hash_kmem, GFP_KERNEL);
 		if (new_f == NULL)
 			goto out_free_new_fa;
 
Index: linux-2.6.19-rc6-mm1/net/ipv4/fib_trie.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/fib_trie.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/fib_trie.c	2006-11-28 16:11:24.000000000 -0800
@@ -1187,7 +1187,7 @@
 			u8 state;
 
 			err = -ENOBUFS;
-			new_fa = kmem_cache_alloc(fn_alias_kmem, SLAB_KERNEL);
+			new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
 			if (new_fa == NULL)
 				goto out;
 
@@ -1232,7 +1232,7 @@
 		goto out;
 
 	err = -ENOBUFS;
-	new_fa = kmem_cache_alloc(fn_alias_kmem, SLAB_KERNEL);
+	new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
 	if (new_fa == NULL)
 		goto out;
 
Index: linux-2.6.19-rc6-mm1/net/decnet/dn_table.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/decnet/dn_table.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/decnet/dn_table.c	2006-11-28 16:11:24.000000000 -0800
@@ -590,7 +590,7 @@
 
 replace:
 	err = -ENOBUFS;
-	new_f = kmem_cache_alloc(dn_hash_kmem, SLAB_KERNEL);
+	new_f = kmem_cache_alloc(dn_hash_kmem, GFP_KERNEL);
 	if (new_f == NULL)
 		goto out;
 
Index: linux-2.6.19-rc6-mm1/net/sunrpc/rpc_pipe.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sunrpc/rpc_pipe.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sunrpc/rpc_pipe.c	2006-11-28 16:11:24.000000000 -0800
@@ -142,7 +142,7 @@
 rpc_alloc_inode(struct super_block *sb)
 {
 	struct rpc_inode *rpci;
-	rpci = (struct rpc_inode *)kmem_cache_alloc(rpc_inode_cachep, SLAB_KERNEL);
+	rpci = (struct rpc_inode *)kmem_cache_alloc(rpc_inode_cachep, GFP_KERNEL);
 	if (!rpci)
 		return NULL;
 	return &rpci->vfs_inode;
Index: linux-2.6.19-rc6-mm1/net/socket.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/socket.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/socket.c	2006-11-28 16:11:24.000000000 -0800
@@ -237,7 +237,7 @@
 {
 	struct socket_alloc *ei;
 
-	ei = kmem_cache_alloc(sock_inode_cachep, SLAB_KERNEL);
+	ei = kmem_cache_alloc(sock_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
 	init_waitqueue_head(&ei->socket.wait);
Index: linux-2.6.19-rc6-mm1/security/keys/key.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/keys/key.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/keys/key.c	2006-11-28 16:11:24.000000000 -0800
@@ -285,7 +285,7 @@
 	}
 
 	/* allocate and initialise the key and its description */
-	key = kmem_cache_alloc(key_jar, SLAB_KERNEL);
+	key = kmem_cache_alloc(key_jar, GFP_KERNEL);
 	if (!key)
 		goto no_memory_2;
 
Index: linux-2.6.19-rc6-mm1/security/selinux/ss/avtab.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/selinux/ss/avtab.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/selinux/ss/avtab.c	2006-11-28 16:11:24.000000000 -0800
@@ -36,7 +36,7 @@
 		  struct avtab_key *key, struct avtab_datum *datum)
 {
 	struct avtab_node * newnode;
-	newnode = kmem_cache_alloc(avtab_node_cachep, SLAB_KERNEL);
+	newnode = kmem_cache_alloc(avtab_node_cachep, GFP_KERNEL);
 	if (newnode == NULL)
 		return NULL;
 	memset(newnode, 0, sizeof(struct avtab_node));
Index: linux-2.6.19-rc6-mm1/security/selinux/hooks.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/selinux/hooks.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/selinux/hooks.c	2006-11-28 16:11:24.000000000 -0800
@@ -181,7 +181,7 @@
 	struct task_security_struct *tsec = current->security;
 	struct inode_security_struct *isec;
 
-	isec = kmem_cache_alloc(sel_inode_cache, SLAB_KERNEL);
+	isec = kmem_cache_alloc(sel_inode_cache, GFP_KERNEL);
 	if (!isec)
 		return -ENOMEM;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
