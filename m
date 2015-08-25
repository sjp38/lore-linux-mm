Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id DF9549003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:04:42 -0400 (EDT)
Received: by ykll84 with SMTP id l84so156311728ykl.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:04:42 -0700 (PDT)
Received: from m12-18.163.com (m12-18.163.com. [220.181.12.18])
        by mx.google.com with ESMTP id u197si12464268ywf.194.2015.08.25.07.04.41
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 07:04:42 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 1/2] mm/page_alloc: change sysctl_lower_zone_reserve_ratio to sysctl_lowmem_reserve_ratio
Date: Tue, 25 Aug 2015 22:01:30 +0800
Message-Id: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

We use sysctl_lowmem_reserve_ratio rather than sysctl_lower_zone_reserve_ratio to
determine how aggressive the kernel is in defending lowmem from the possibility of
being captured into pinned user memory. To avoid misleading, correct it in some
comments.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a0acdb..b730f7d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6043,7 +6043,7 @@ void __init page_alloc_init(void)
 }
 
 /*
- * calculate_totalreserve_pages - called when sysctl_lower_zone_reserve_ratio
+ * calculate_totalreserve_pages - called when sysctl_lowmem_reserve_ratio
  *	or min_free_kbytes changes.
  */
 static void calculate_totalreserve_pages(void)
@@ -6087,7 +6087,7 @@ static void calculate_totalreserve_pages(void)
 
 /*
  * setup_per_zone_lowmem_reserve - called whenever
- *	sysctl_lower_zone_reserve_ratio changes.  Ensures that each zone
+ *	sysctl_lowmem_reserve_ratio changes.  Ensures that each zone
  *	has a correct pages reserved value, so an adequate number of
  *	pages are left in the zone after a successful __alloc_pages().
  */
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
