Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 245036B0072
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:17:05 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so14883139pdb.4
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:17:04 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id nz4si411966pdb.0.2015.02.12.14.17.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 12 Feb 2015 14:17:04 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJO005LMJF7OEA0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 12 Feb 2015 22:21:07 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH 3/4] mm: cma: add number of pages to debug message in
 cma_release()
Date: Fri, 13 Feb 2015 01:15:43 +0300
Message-id: 
 <343ef6ddea30d62ca001f84a8febbb311a1ac2da.1423777850.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1423777850.git.s.strogin@partner.samsung.com>
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1423777850.git.s.strogin@partner.samsung.com>
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

It's more useful to print address and number of pages which are being released,
not olny address.

Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
---
 mm/cma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index 95e8121..c68d383 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -467,7 +467,7 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
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
