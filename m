Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9EC28600374
	for <linux-mm@kvack.org>; Wed,  5 May 2010 08:19:42 -0400 (EDT)
Date: Wed, 5 May 2010 14:19:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] fix count_vm_event preempt in memory compaction direct
 reclaim
Message-ID: <20100505121908.GA5835@random.random>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
 <1271797276-31358-13-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271797276-31358-13-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 10:01:14PM +0100, Mel Gorman wrote:
> +		if (page) {
> +			__count_vm_event(COMPACTSUCCESS);
> +			return page;

==
From: Andrea Arcangeli <aarcange@redhat.com>

Preempt is enabled so it must use count_vm_event.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1768,7 +1768,7 @@ __alloc_pages_direct_compact(gfp_t gfp_m
 				alloc_flags, preferred_zone,
 				migratetype);
 		if (page) {
-			__count_vm_event(COMPACTSUCCESS);
+			count_vm_event(COMPACTSUCCESS);
 			return page;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
