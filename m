Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6D27F6B0098
	for <linux-mm@kvack.org>; Mon, 25 May 2015 12:39:07 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so74025965pab.1
        for <linux-mm@kvack.org>; Mon, 25 May 2015 09:39:07 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id pv10si16825903pbc.93.2015.05.25.09.39.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 09:39:06 -0700 (PDT)
Received: by padbw4 with SMTP id bw4so74025363pad.0
        for <linux-mm@kvack.org>; Mon, 25 May 2015 09:39:06 -0700 (PDT)
From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] mm:vmscan - Fix for typo in comment in function __remove_mapping().
Date: Mon, 25 May 2015 22:08:51 +0530
Message-Id: <1432571931-2789-1-git-send-email-shailendra.capricorn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Shailendra Verma <shailendra.capricorn@gmail.com>


Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..68a0d04 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -632,7 +632,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		 * order to detect refaults, thus thrashing, later on.
 		 *
 		 * But don't store shadows in an address space that is
-		 * already exiting.  This is not just an optizimation,
+		 * already exiting.  This is not just an optimization,
 		 * inode reclaim needs to empty out the radix tree or
 		 * the nodes are lost.  Don't plant shadows behind its
 		 * back.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
