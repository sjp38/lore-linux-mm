Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6CE1F6B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 10:03:03 -0400 (EDT)
Date: Fri, 9 Jul 2010 09:02:31 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] vmscan: stop meaningless loop iteration when no reclaimable
 slab
In-Reply-To: <20100709191308.FA25.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1007090859560.30663@router.home>
References: <20100708133152.5e556508.akpm@linux-foundation.org> <20100709171850.FA22.A69D9226@jp.fujitsu.com> <20100709191308.FA25.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jul 2010, KOSAKI Motohiro wrote:

> If number of reclaimable slabs are zero, shrink_icache_memory() and
> shrink_dcache_memory() return 0. but strangely shrink_slab() ignore
> it and continue meaningless loop iteration.

There is also a per zone/node/global counter SLAB_RECLAIM_ACCOUNT that
could be used to determine if its worth looking at things at all. I saw
some effort going into making the shrinkers zone aware. If so then we may
be able to avoid scanning slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
