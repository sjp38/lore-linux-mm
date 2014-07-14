Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 67F456B0038
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 09:21:07 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so1960475wgh.10
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 06:21:04 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pb9si15802295wjb.143.2014.07.14.06.20.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 06:20:59 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: vmscan: rework compaction-ready signaling in direct reclaim fix
Date: Mon, 14 Jul 2014 09:20:47 -0400
Message-Id: <1405344049-19868-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As per Mel, replace out label with breaks from the loop.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 35747a75bf08..6f43df4a5253 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2496,10 +2496,10 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
-			goto out;
+			break;
 
 		if (sc->compaction_ready)
-			goto out;
+			break;
 
 		/*
 		 * If we're getting trouble reclaiming, start doing
@@ -2523,7 +2523,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		}
 	} while (--sc->priority >= 0);
 
-out:
 	delayacct_freepages_end();
 
 	if (sc->nr_reclaimed)
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
