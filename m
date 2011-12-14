Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 094F76B02E5
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:41:38 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/11] mm: compaction: Use synchronous compaction for /proc/sys/vm/compact_memory
Date: Wed, 14 Dec 2011 15:41:24 +0000
Message-Id: <1323877293-15401-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-1-git-send-email-mgorman@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When asynchronous compaction was introduced, the
/proc/sys/vm/compact_memory handler should have been updated to always
use synchronous compaction. This did not happen so this patch addresses
it. The assumption is if a user writes to /proc/sys/vm/compact_memory,
they are willing for that process to stall.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 237560e..615502b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -666,6 +666,7 @@ static int compact_node(int nid)
 			.nr_freepages = 0,
 			.nr_migratepages = 0,
 			.order = -1,
+			.sync = true,
 		};
 
 		zone = &pgdat->node_zones[zoneid];
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
