Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0696B0038
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:27:53 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so3448515pbc.17
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:27:53 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id sg10si10267765pbb.249.2014.06.16.02.27.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 02:27:52 -0700 (PDT)
Message-ID: <539EB7FE.1070009@huawei.com>
Date: Mon, 16 Jun 2014 17:25:18 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 7/8] mm: implement page cache reclaim speed
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

The parameter vm_cache_reclaim_weight means every time we expect to
reclaim SWAP_CLUSTER_MAX * vm_cache_reclaim_weight pages.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d179be6..23b808a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3430,7 +3430,7 @@ static unsigned long __shrink_page_cache(gfp_t mask)
 	struct scan_control sc = {
 		.gfp_mask = (mask = memalloc_noio_flags(mask)),
 		.may_writepage = !laptop_mode,
-		.nr_to_reclaim = SWAP_CLUSTER_MAX,
+		.nr_to_reclaim = SWAP_CLUSTER_MAX * vm_cache_reclaim_weight,
 		.may_unmap = 1,
 		.may_swap = 1,
 		.order = 0,
-- 
1.6.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
