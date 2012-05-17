Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 7E0BC6B00E8
	for <linux-mm@kvack.org>; Thu, 17 May 2012 06:55:05 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M4500593YC6HY40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 11:55:18 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4500MKCYBFX2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 11:55:03 +0100 (BST)
Date: Thu, 17 May 2012 12:54:44 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 3/4] mm: vmalloc: add VM_DMA flag to indicate areas used by
 dma-mapping framework
In-reply-to: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1337252085-22039-4-git-send-email-m.szyprowski@samsung.com>
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Add new type of vm_area intented to be used for consisten mappings
created by dma-mapping framework.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/vmalloc.h |    1 +
 mm/vmalloc.c            |    3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 6071e91..8a9555a 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -14,6 +14,7 @@ struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 #define VM_USERMAP	0x00000008	/* suitable for remap_vmalloc_range */
 #define VM_VPAGES	0x00000010	/* buffer for pages was vmalloc'ed */
 #define VM_UNLIST	0x00000020	/* vm_struct is not listed in vmlist */
+#define VM_DMA		0x00000040	/* used by dma-mapping framework */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8cb7f22..9c13bab 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2582,6 +2582,9 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->flags & VM_IOREMAP)
 		seq_printf(m, " ioremap");
 
+	if (v->flags & VM_DMA)
+		seq_printf(m, " dma");
+
 	if (v->flags & VM_ALLOC)
 		seq_printf(m, " vmalloc");
 
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
