Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 88CA86B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 06:55:04 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M450068GYAG6D40@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 11:54:16 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4500MKCYBFX2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 11:55:02 +0100 (BST)
Date: Thu, 17 May 2012 12:54:43 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 2/4] mm: vmalloc: export find_vm_area() function
In-reply-to: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1337252085-22039-3-git-send-email-m.szyprowski@samsung.com>
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

find_vm_area() function is usefull for other core subsystems (like
dma-mapping) to get access to vm_area internals.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/vmalloc.h |    1 +
 mm/vmalloc.c            |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 2e28f4d..6071e91 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -93,6 +93,7 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 					unsigned long start, unsigned long end,
 					const void *caller);
 extern struct vm_struct *remove_vm_area(const void *addr);
+extern struct vm_struct *find_vm_area(const void *addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page ***pages);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8bc7f3ef..8cb7f22 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1402,7 +1402,15 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 						-1, GFP_KERNEL, caller);
 }
 
-static struct vm_struct *find_vm_area(const void *addr)
+/**
+ *	find_vm_area  -  find a continuous kernel virtual area
+ *	@addr:		base address
+ *
+ *	Search for the kernel VM area starting at @addr, and return it.
+ *	It is up to the caller to do all required locking to keep the returned
+ *	pointer valid.
+ */
+struct vm_struct *find_vm_area(const void *addr)
 {
 	struct vmap_area *va;
 
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
