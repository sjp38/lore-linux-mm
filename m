Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3438D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 07:23:24 -0400 (EDT)
Received: by bwz17 with SMTP id 17so7930739bwz.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 04:23:20 -0700 (PDT)
Date: Tue, 22 Mar 2011 13:26:47 +0200
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] mm: remove unused zone_idx variable from
 set_migratetype_isolate
Message-ID: <20110322112647.GA5086@swordfish.minsk.epam.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mm: remove unused variable zone_idx and zone_idx call from set_migratetype_isolate

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 mm/page_alloc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7945247..b732240 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5414,10 +5414,8 @@ int set_migratetype_isolate(struct page *page)
 	struct memory_isolate_notify arg;
 	int notifier_ret;
 	int ret = -EBUSY;
-	int zone_idx;
 
 	zone = page_zone(page);
-	zone_idx = zone_idx(zone);
 
 	spin_lock_irqsave(&zone->lock, flags);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
