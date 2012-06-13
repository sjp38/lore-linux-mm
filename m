Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 939296B0075
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 07:02:25 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5J0067UYNZQY70@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 13 Jun 2012 20:02:24 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5J00EDHYN9NO40@mmp2.samsung.com> for linux-mm@kvack.org;
 Wed, 13 Jun 2012 20:02:23 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv3 2/3] mm: vmalloc: add VM_DMA flag to indicate areas used by
 dma-mapping framework
Date: Wed, 13 Jun 2012 13:01:45 +0200
Message-id: <1339585306-7147-3-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1339585306-7147-1-git-send-email-m.szyprowski@samsung.com>
References: <1339585306-7147-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>, Minchan Kim <minchan@kernel.org>

Add new type of vm_area intented to be used for mappings created by
dma-mapping framework.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/vmalloc.h |    1 +
 mm/vmalloc.c            |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 2e28f4d..e725b7b 100644
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
index 11308f0..e04d59b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2575,6 +2575,9 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->flags & VM_IOREMAP)
 		seq_printf(m, " ioremap");
 
+	if (v->flags & VM_DMA)
+		seq_printf(m, " dma");
+
 	if (v->flags & VM_ALLOC)
 		seq_printf(m, " vmalloc");
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
