Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 937256B0022
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:34:22 -0400 (EDT)
Received: by wwi36 with SMTP id 36so6203517wwi.26
        for <linux-mm@kvack.org>; Tue, 24 May 2011 06:34:19 -0700 (PDT)
Date: Tue, 24 May 2011 15:34:14 +0200
From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH] set_migratetype_isolate: remove unused variable.
Message-ID: <20110524133414.GA11674@nb-core2.darkstar.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
---
 mm/page_alloc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d5498e..bcbdaf1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5508,10 +5508,8 @@ int set_migratetype_isolate(struct page *page)
 	struct memory_isolate_notify arg;
 	int notifier_ret;
 	int ret = -EBUSY;
-	int zone_idx;
 
 	zone = page_zone(page);
-	zone_idx = zone_idx(zone);
 
 	spin_lock_irqsave(&zone->lock, flags);
 
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
