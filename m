Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id CFB086B0071
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:45:10 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so35263755pdb.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:45:10 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id rf8si2334902pab.79.2015.02.24.10.45.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Feb 2015 10:45:09 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKA00GDTHLUK850@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Feb 2015 18:49:06 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH v3 2/4] mm: cma: add number of pages to debug message in
 cma_release()
Date: Tue, 24 Feb 2015 21:44:33 +0300
Message-id: 
 <a0c78bd29b1aa0bccb461ebd675716c0b1a2caf3.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

It's more useful to print address and number of pages which are being released,
not only address.

Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
---
 mm/cma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index 3a63c96..111bf62 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -434,7 +434,7 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
 	if (!cma || !pages)
 		return false;
 
-	pr_debug("%s(page %p)\n", __func__, (void *)pages);
+	pr_debug("%s(page %p, count %d)\n", __func__, (void *)pages, count);
 
 	pfn = page_to_pfn(pages);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
