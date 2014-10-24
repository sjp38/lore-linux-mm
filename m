Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5E66B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 05:49:17 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so869411pac.2
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 02:49:17 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id jd12si3874616pbd.10.2014.10.24.02.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 24 Oct 2014 02:49:17 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NDY00L0S0M29KB0@mailout2.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Oct 2014 18:49:15 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm, cma: make parameters order consistent in func declaration
 and definition
Date: Fri, 24 Oct 2014 17:47:57 +0800
Message-id: <000201cfef6f$c5422b10$4fc68130$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mina86@mina86.com
Cc: m.szyprowski@samsung.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

In the current code, the base and size parameters order is not consistent
in functions declaration and definition. If someone calls these functions
according to the declaration parameters order in cma.h, he will run into
some bug and it's hard to find the reason.

This patch makes the parameters order consistent in functions declaration
and definition.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 include/linux/cma.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 0430ed0..a93438b 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -18,12 +18,12 @@ struct cma;
 extern phys_addr_t cma_get_base(struct cma *cma);
 extern unsigned long cma_get_size(struct cma *cma);
 
-extern int __init cma_declare_contiguous(phys_addr_t size,
-			phys_addr_t base, phys_addr_t limit,
+extern int __init cma_declare_contiguous(phys_addr_t base,
+			phys_addr_t size, phys_addr_t limit,
 			phys_addr_t alignment, unsigned int order_per_bit,
 			bool fixed, struct cma **res_cma);
-extern int cma_init_reserved_mem(phys_addr_t size,
-					phys_addr_t base, int order_per_bit,
+extern int cma_init_reserved_mem(phys_addr_t base,
+					phys_addr_t size, int order_per_bit,
 					struct cma **res_cma);
 extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
 extern bool cma_release(struct cma *cma, struct page *pages, int count);
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
