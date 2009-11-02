Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D853D6B007B
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:35:43 -0500 (EST)
Date: Tue, 3 Nov 2009 00:35:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCHv2 1/5] vmscan: separate sc.swap_cluster_max and sc.nr_max_reclaim
In-Reply-To: <20091102093517.32021780.minchan.kim@barrios-desktop>
References: <20091101234614.F401.A69D9226@jp.fujitsu.com> <20091102093517.32021780.minchan.kim@barrios-desktop>
Message-Id: <20091103001211.8866.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> > @@ -1932,6 +1938,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
> >  		.may_unmap = 1,
> >  		.may_swap = 1,
> >  
> 		.swap_cluster_max = SWAP_CLUSTER_MAX,
> Or add comment in here. 
> 
> 'kswapd doesn't want to be bailed out while reclaim.'

OK, reasonable.
How about this?



---
 mm/vmscan.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7fb3435..84e4da0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1930,6 +1930,10 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
 		.may_swap = 1,
+		/*
+		 * kswapd doesn't want to be bailed out while reclaim. because
+		 * we want to put equal scanning pressure on each zone.
+		 */
 		.nr_to_reclaim = ULONG_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
-- 
1.6.2.5




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
