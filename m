Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D3F496B00B2
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 20:56:04 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: fix vmstat and zonestat mismatch
Date: Wed,  4 Jul 2012 09:56:41 +0900
Message-Id: <1341363401-19326-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

e975d6ac[1] in linux-next removed NUMA_INTERLEAVE_HIT
in zone_stat_item but didn't remove it in vmstat_text
so that cat /proc/vmstat doesn't show right count number.

[1]: mm/mpol: Remove NUMA_INTERLEAVE_HIT

Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmstat.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1bbbbd9..e4db312 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -717,7 +717,6 @@ const char * const vmstat_text[] = {
 	"numa_hit",
 	"numa_miss",
 	"numa_foreign",
-	"numa_interleave",
 	"numa_local",
 	"numa_other",
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
