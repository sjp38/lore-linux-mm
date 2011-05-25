Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A2E5A6B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:32:10 -0400 (EDT)
Received: by wyf19 with SMTP id 19so31198wyf.14
        for <linux-mm@kvack.org>; Wed, 25 May 2011 13:32:06 -0700 (PDT)
Date: Wed, 25 May 2011 22:31:58 +0200
From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH v2] set_migratetype_isolate: remove unused variable.
Message-ID: <20110525203128.GA16833@nb-core2.darkstar.lan>
References: <20110524133414.GA11674@nb-core2.darkstar.lan>
 <BANLkTikEz0k8WTCAW9x7dYK2i3mm4c7tLA@mail.gmail.com>
 <BANLkTi=X1APdoMPE-P+xr-ADv8ivx90z-g@mail.gmail.com>
 <4DDCB160.8040009@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DDCB160.8040009@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

zone_idx is never read inside the function.

Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
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
