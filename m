Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 068626B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:06:03 -0400 (EDT)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2F007QA8G9UZ@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 13 Apr 2012 15:04:57 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2F00GWW8HZDZ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 13 Apr 2012 15:05:59 +0100 (BST)
Date: Fri, 13 Apr 2012 16:05:48 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 2/4] mm: vmalloc: export find_vm_area() function
In-reply-to: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1334325950-7881-3-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com>
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
 2 files changed, 10 insertions(+), 1 deletions(-)

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
index 8bc7f3e..8cb7f22 100644
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
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
