Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A31B46B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 18:56:51 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so3624458qcs.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 15:56:50 -0700 (PDT)
Date: Fri, 21 Sep 2012 15:56:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/4] mm: remove unevictable_pgs_mlockfreed
In-Reply-To: <20120921124715.GD11157@csn.ul.ie>
Message-ID: <alpine.LSU.2.00.1209211550180.23812@eggly.anvils>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils> <alpine.LSU.2.00.1209182055290.11632@eggly.anvils> <20120921124715.GD11157@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Simply remove UNEVICTABLE_MLOCKFREED and unevictable_pgs_mlockfreed
line from /proc/vmstat: Johannes and Mel point out that it was very
unlikely to have been used by any tool, and of course we can restore
it easily enough if that turns out to be wrong.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Ying Han <yinghan@google.com>
---
 include/linux/vm_event_item.h |    1 -
 mm/vmstat.c                   |    1 -
 2 files changed, 2 deletions(-)

--- 3.6-rc6.orig/include/linux/vm_event_item.h	2012-09-18 20:04:42.000000000 -0700
+++ 3.6-rc6/include/linux/vm_event_item.h	2012-09-21 15:13:26.608016171 -0700
@@ -52,7 +52,6 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGMUNLOCKED,
 		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
-		UNEVICTABLE_MLOCKFREED,	/* no longer useful: always zero */
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		THP_FAULT_ALLOC,
 		THP_FAULT_FALLBACK,
--- 3.6-rc6.orig/mm/vmstat.c	2012-09-18 20:04:42.000000000 -0700
+++ 3.6-rc6/mm/vmstat.c	2012-09-21 15:13:43.724017386 -0700
@@ -781,7 +781,6 @@ const char * const vmstat_text[] = {
 	"unevictable_pgs_munlocked",
 	"unevictable_pgs_cleared",
 	"unevictable_pgs_stranded",
-	"unevictable_pgs_mlockfreed",	/* no longer useful: always zero */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	"thp_fault_alloc",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
