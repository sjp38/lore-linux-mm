Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFDD6B00CF
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 13:34:49 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id k14so829187wgh.24
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 10:34:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si4785544wiy.73.2014.11.14.10.34.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Nov 2014 10:34:48 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] mm: do not overwrite reserved pages counter at show_mem()
Date: Fri, 14 Nov 2014 13:34:29 -0500
Message-Id: <e34cbf786f7c16d4330889825aa5b13141cc085c.1415989668.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

Minor fixlet to perform the reserved pages counter aggregation
for each node, at show_mem()

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 lib/show_mem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/show_mem.c b/lib/show_mem.c
index 0922579..5e25627 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -28,7 +28,7 @@ void show_mem(unsigned int filter)
 				continue;
 
 			total += zone->present_pages;
-			reserved = zone->present_pages - zone->managed_pages;
+			reserved += zone->present_pages - zone->managed_pages;
 
 			if (is_highmem_idx(zoneid))
 				highmem += zone->present_pages;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
