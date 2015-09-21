Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id D58CD6B0256
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:36:28 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so119507198pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:36:28 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id kw9si37816010pab.114.2015.09.21.06.36.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:36:27 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NV1005VX4GNSH60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 21 Sep 2015 14:36:23 +0100 (BST)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 33/38] mm/memblock.c: remove invalid check
Date: Mon, 21 Sep 2015 15:34:05 +0200
Message-id: <1442842450-29769-34-git-send-email-a.hajda@samsung.com>
In-reply-to: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Kuleshov <kuleshovmail@gmail.com>, Tony Luck <tony.luck@intel.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, linux-mm@kvack.org

Unsigned value cannot be lesser than zero.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index d300f13..aeb5148 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -837,7 +837,7 @@ void __init_memblock __next_reserved_mem_region(u64 *idx,
 {
 	struct memblock_type *type = &memblock.reserved;
 
-	if (*idx >= 0 && *idx < type->cnt) {
+	if (*idx < type->cnt) {
 		struct memblock_region *r = &type->regions[*idx];
 		phys_addr_t base = r->base;
 		phys_addr_t size = r->size;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
