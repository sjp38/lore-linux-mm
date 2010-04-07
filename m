Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 85C546B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 14:27:28 -0400 (EDT)
Date: Wed, 7 Apr 2010 19:27:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09/14] Add /proc trigger for memory compaction
Message-ID: <20100407182707.GX17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-10-git-send-email-mel@csn.ul.ie> <20100406170555.1efe35b0.akpm@linux-foundation.org> <20100407153910.GR17882@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100407153910.GR17882@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> mm,compaction: Tighten up the allowed values for compact_memory and initialisation
> 

Minor mistake in the initialisation part of the patch

==== CUT HERE ====
mm,compaction: Initialise cc->zone at the correct time

Init cc->zone after we know what zone we are looking for. This is a fix
to the fix patch "mm,compaction: Tighten up the allowed values for
compact_memory and initialisation"

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/compaction.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index d9c5733..effe57d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -396,13 +396,13 @@ static int compact_node(int nid)
 		struct compact_control cc = {
 			.nr_freepages = 0,
 			.nr_migratepages = 0,
-			.zone = zone,
 		};
 
 		zone = &pgdat->node_zones[zoneid];
 		if (!populated_zone(zone))
 			continue;
 
+		cc.zone = zone,
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
