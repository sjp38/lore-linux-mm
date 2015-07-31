Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EDA336B0255
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 15:39:13 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so45351215pac.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 12:39:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x1si12303234pdm.181.2015.07.31.12.39.11
        for <linux-mm@kvack.org>;
        Fri, 31 Jul 2015 12:39:11 -0700 (PDT)
From: "Sean O. Stalley" <sean.stalley@intel.com>
Subject: [PATCH v2 3/4] pci: mm: Add pci_pool_zalloc() call
Date: Fri, 31 Jul 2015 12:36:43 -0700
Message-Id: <1438371404-3219-4-git-send-email-sean.stalley@intel.com>
In-Reply-To: <1438371404-3219-1-git-send-email-sean.stalley@intel.com>
References: <1438371404-3219-1-git-send-email-sean.stalley@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, vinod.koul@intel.com, bhelgaas@google.com, Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr, nicolas.palix@imag.fr, mmarek@suse.cz, akpm@linux-foundation.org
Cc: sean.stalley@intel.com, bigeasy@linutronix.de, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, dmaengine@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, cocci@systeme.lip6.fr

Add a wrapper function for pci_pool_alloc() to get zeroed memory.

Signed-off-by: Sean O. Stalley <sean.stalley@intel.com>
---
 include/linux/pci.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index 755a2cd..e6ec7d9 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1176,6 +1176,8 @@ int pci_set_vga_state(struct pci_dev *pdev, bool decode,
 		dma_pool_create(name, &pdev->dev, size, align, allocation)
 #define	pci_pool_destroy(pool) dma_pool_destroy(pool)
 #define	pci_pool_alloc(pool, flags, handle) dma_pool_alloc(pool, flags, handle)
+#define	pci_pool_zalloc(pool, flags, handle) \
+		dma_pool_zalloc(pool, flags, handle)
 #define	pci_pool_free(pool, vaddr, addr) dma_pool_free(pool, vaddr, addr)
 
 enum pci_dma_burst_strategy {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
