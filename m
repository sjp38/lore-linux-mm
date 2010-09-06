Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A19A16B0093
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 02:35:18 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L8B002GHBMS8N40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Sep 2010 07:35:16 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8B00IWLBMSPV@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Sep 2010 07:35:16 +0100 (BST)
Date: Mon, 06 Sep 2010 08:33:58 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv5 8/9] mm: vcm: Sample driver added
In-reply-to: <cover.1283749231.git.mina86@mina86.com>
Message-id: 
 <262a5a5019c1f1a44d5793f7e69776e56f27af06.1283749231.git.mina86@mina86.com>
References: <cover.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This commit adds a sample Virtual Contiguous Memory framework
driver.  It handles no real hardware and is there only for
demonstrating purposes.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |    3 +
 include/linux/vcm-sample.h                  |   30 +++++++
 mm/Kconfig                                  |    9 ++
 mm/Makefile                                 |    1 +
 mm/vcm-sample.c                             |  120 +++++++++++++++++++++++++++
 5 files changed, 163 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/vcm-sample.h
 create mode 100644 mm/vcm-sample.c

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index 0c0e90c..6d1014c 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -730,6 +730,9 @@ already there.
 If you want to use this wrapper, you need to select VCM_MMU Kconfig
 option.
 
+There is a sample driver provided which provides a template for real
+drivers.  It can be found in [[file:../mm/vcm-sample.c][mm/vcm-sample.c]] file.
+
 *** Context creation
 
 Similarly to normal drivers, MMU driver needs to provide a context
diff --git a/include/linux/vcm-sample.h b/include/linux/vcm-sample.h
new file mode 100644
index 0000000..9a79403
--- /dev/null
+++ b/include/linux/vcm-sample.h
@@ -0,0 +1,30 @@
+/*
+ * Virtual Contiguous Memory driver driver template header
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * See Documentation/virtual-contiguous-memory.txt for details.
+ */
+
+#ifndef __LINUX_VCM_SAMPLE_H
+#define __LINUX_VCM_SAMPLE_H
+
+#include <linux/vcm.h>
+
+struct vcm;
+
+/**
+ * vcm_samp_create() - creates a VCM context
+ *
+ * ... Documentation goes here ...
+ */
+struct vcm *__must_check vcm_samp_create(/* ... */);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 0445f68..be040e7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -401,3 +401,12 @@ config VCM_O2O
 # Select if you need vcm_phys_alloc() or vcm_phys_walk() functions
 config VCM_PHYS
 	bool
+
+config VCM_SAMP
+	bool "VCM sample driver"
+	depends on VCM
+	select VCM_MMU
+	help
+	  This enables a sample driver for the VCM framework.  This driver
+	  does not handle any real harwdare.  It's merely an template of
+	  how for real drivers.
diff --git a/mm/Makefile b/mm/Makefile
index e908202..c465dfa 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -50,3 +50,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CMA) += cma.o
 obj-$(CONFIG_CMA_BEST_FIT) += cma-best-fit.o
 obj-$(CONFIG_VCM) += vcm.o
+obj-$(CONFIG_VCM_SAMPLE) += vcm-sample.o
diff --git a/mm/vcm-sample.c b/mm/vcm-sample.c
new file mode 100644
index 0000000..e265a73
--- /dev/null
+++ b/mm/vcm-sample.c
@@ -0,0 +1,120 @@
+/*
+ * Virtual Contiguous Memory driver template
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * This is just a sample code.  It does nothing useful other then
+ * presenting a template for VCM driver.
+ */
+
+/*
+ * See Documentation/virtual-contiguous-memory.txt for details.
+ */
+
+#include <linux/vcm-drv.h>
+#include <linux/vcm-sample.h>
+
+struct vcm_samp {
+	struct vcm_mmu	mmu;
+	/* ... */
+};
+
+static const unsigned vcm_samp_orders[] = {
+	4 + 20 - PAGES_SHIFT,	/* 16MiB pages */
+	0 + 20 - PAGES_SHIFT,	/*  1MiB pages */
+	6 + 10 - PAGES_SHIFT,	/* 64KiB pages */
+	2 + 10 - PAGES_SHIFT,	/*  4KiB pages */
+};
+
+static int vcm_samp_activate_page(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *priv)
+{
+	struct vcm_samp *samp =
+		container_of((struct vcm *)priv, struct vcm_samp, mmu.vcm);
+
+	/*
+	 * Handle adding a mapping from virtual page at @vaddr to
+	 * physical page ad @paddr.  The page is of order @order which
+	 * means that it's (PAGE_SIZE << @order) bytes.
+	 */
+
+	return -EOPNOTSUPP;
+}
+
+static int vcm_samp_deactivate_page(dma_addr_t vaddr, dma_addr_t paddr,
+				    unsigned order, void *priv)
+{
+	struct vcm_samp *samp =
+		container_of((struct vcm *)priv, struct vcm_samp, mmu.vcm);
+
+	/*
+	 * Handle removing a mapping from virtual page at @vaddr to
+	 * physical page ad @paddr.  The page is of order @order which
+	 * means that it's (PAGE_SIZE << @order) bytes.
+	 */
+
+	/* It's best not to fail here */
+	return 0;
+}
+
+static void vcm_samp_cleanup(struct vcm *vcm)
+{
+	struct vcm_samp *samp =
+		container_of(res->vcm, struct vcm_samp, mmu.vcm);
+
+	/* Clean ups ... */
+
+	kfree(samp);
+}
+
+struct vcm *__must_check vcm_samp_create(/* ... */)
+{
+	static const struct vcm_mmu_driver driver = {
+		.order           = vcm_samp_orders,
+		.cleanup         = vcm_samp_cleanup,
+		.activate_page   = vcm_samp_activate_page,
+		.deactivate_page = vcm_samp_deactivate_page,
+	};
+
+	struct vcm_samp *samp;
+	struct vcm *vcm;
+
+	switch (0) {
+	case 0:
+	case PAGE_SHIFT == 12:
+		/*
+		 * If you have a compilation error here it means you
+		 * are compiling for a very strange platfrom where
+		 * PAGE_SHIFT is not 12 (ie. PAGE_SIZE is not 4KiB).
+		 * This driver assumes PAGE_SHIFT is 12.
+		 */
+	};
+
+	samp = kzalloc(sizeof *samp, GFP_KERNEL);
+	if (!samp)
+		return ERR_PTR(-ENOMEM);
+
+	/* ... Set things up ... */
+
+	samp->mmu.driver    = &driver;
+	/* skip first 64K so that zero address will be a NULL pointer */
+	samp->mmu.vcm.start =  (64 << 10);
+	samp->mmu.vcm.size  = -(64 << 10);
+
+	vcm = vcm_mmu_init(&samp->mmu);
+	if (!IS_ERR(vcm))
+		return vcm;
+
+	/* ... Error recovery ... */
+
+	kfree(samp);
+	return vcm;
+}
+EXPORT_SYMBOL_GPL(vcm_samp_create);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
