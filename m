Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1E99A6B0082
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 07:46:26 -0400 (EDT)
Date: Tue, 19 Jul 2011 12:46:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page allocator: Reconsider zones for allocation after
 direct reclaim fix
Message-ID: <20110719114619.GG5349@suse.de>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de>
 <1310742540-22780-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1310742540-22780-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


mm/page_alloc.c: In function a??__alloc_pages_direct_reclaima??:
mm/page_alloc.c:1983:3: error: implicit declaration of function a??zlc_clear_zones_fulla??

This patch is a build fix for !CONFIG_NUMA that should be merged with
mm-page-allocator-reconsider-zones-for-allocation-after-direct-reclaim.patch .

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 149409c..0f50cdb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1647,6 +1647,10 @@ static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zoneref *z,
 static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
 {
 }
+
+static void zlc_clear_zones_full(struct zonelist *zonelist)
+{
+}
 #endif	/* CONFIG_NUMA */
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
