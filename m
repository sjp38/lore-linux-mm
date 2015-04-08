Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CE3CC6B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 15:45:45 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so124125175pac.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 12:45:45 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id h8si18028523pde.174.2015.04.08.12.45.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 08 Apr 2015 12:45:44 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NMI003QR72QUP70@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 08 Apr 2015 20:49:38 +0100 (BST)
From: Dmitry Safonov <d.safonov@partner.samsung.com>
Subject: [PATCH] mm-cma-add-functions-to-get-region-pages-counters-fix-3
Date: Wed, 08 Apr 2015 22:45:36 +0300
Message-id: <1428522336-9020-1-git-send-email-d.safonov@partner.samsung.com>
In-reply-to: <20150408140446.GR16501@mwanda>
References: <20150408140446.GR16501@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.carpenter@oracle.com
Cc: kbuild@01.org, stefan.strogin@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.cz>

Fix for the next compiler warnings:
mm/cma_debug.c:45 cma_used_get() warn: should 'used << cma->order_per_bit' be a 64 bit type?
mm/cma_debug.c:67 cma_maxchunk_get() warn: should 'maxchunk << cma->order_per_bit' be a 64 bit type?

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Stefan Strogin <stefan.strogin@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pintu Kumar <pintu.k@samsung.com>
Cc: Weijie Yang <weijie.yang@samsung.com>
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Cc: Vyacheslav Tyrtov <v.tyrtov@samsung.com>
Cc: Aleksei Mateosian <a.mateosian@samsung.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
---
 mm/cma_debug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 835e761..9459842 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -42,7 +42,7 @@ static int cma_used_get(void *data, u64 *val)
 	/* pages counter is smaller than sizeof(int) */
 	used = bitmap_weight(cma->bitmap, (int)cma->count);
 	mutex_unlock(&cma->lock);
-	*val = used << cma->order_per_bit;
+	*val = (u64)used << cma->order_per_bit;
 
 	return 0;
 }
@@ -64,7 +64,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
 		maxchunk = max(end - start, maxchunk);
 	}
 	mutex_unlock(&cma->lock);
-	*val = maxchunk << cma->order_per_bit;
+	*val = (u64)maxchunk << cma->order_per_bit;
 
 	return 0;
 }
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
