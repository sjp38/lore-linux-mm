Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id AE4976B003B
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 09:30:10 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so8680070pbb.14
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 06:30:10 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUC00EXPQT6AJ20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Oct 2013 14:30:06 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH v3 4/6] zbud: memset zbud_header to 0 during init
Date: Tue, 08 Oct 2013 15:29:38 +0200
Message-id: <1381238980-2491-5-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

memset zbud_header to 0 during init instead of manually assigning 0 to
members. Currently only two members needs to be initialized to 0 but
further patches will add more of them.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 mm/zbud.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 6db0557..0edd880 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -133,8 +133,7 @@ static int size_to_chunks(int size)
 static struct zbud_header *init_zbud_page(struct page *page)
 {
 	struct zbud_header *zhdr = page_address(page);
-	zhdr->first_chunks = 0;
-	zhdr->last_chunks = 0;
+	memset(zhdr, 0, sizeof(*zhdr));
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_LIST_HEAD(&zhdr->lru);
 	return zhdr;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
