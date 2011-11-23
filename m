Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9F53A6B00A6
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 00:55:40 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so1250730vbb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 21:55:38 -0800 (PST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: add task name to warn_scan_unevictable() messages
Date: Wed, 23 Nov 2011 00:55:20 -0500
Message-Id: <1322027721-23677-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

If we need to know a usecase, caller program name is critical important.
Show it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1893c0..29d163e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3448,9 +3448,10 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 static void warn_scan_unevictable_pages(void)
 {
 	printk_once(KERN_WARNING
-		    "The scan_unevictable_pages sysctl/node-interface has been "
+		    "%s: The scan_unevictable_pages sysctl/node-interface has been "
 		    "disabled for lack of a legitimate use case.  If you have "
-		    "one, please send an email to linux-mm@kvack.org.\n");
+		    "one, please send an email to linux-mm@kvack.org.\n",
+		    current->comm);
 }
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
