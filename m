Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B664A6B03B2
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 08:45:29 -0400 (EDT)
Date: Mon, 23 Aug 2010 07:45:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] Reduce watermark-related problems with the per-cpu
 allocator V2
In-Reply-To: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1008230742300.4094@router.home>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Mel Gorman wrote:

> Internal IBM test teams beta testing distribution kernels have reported
> problems on machines with a large number of CPUs whereby page allocator
> failure messages show huge differences between the nr_free_pages vmstat
> counter and what is available on the buddy lists. In an extreme example,
> nr_free_pages was above the min watermark but zero pages were on the buddy
> lists allowing the system to potentially livelock unable to make forward
> progress unless an allocation succeeds. There is no reason why the problems
> would not affect mainline so the following series mitigates the problems
> in the page allocator related to to per-cpu counter drift and lists.

The maximum time for which the livelock can exists is the vm stat
interval. By default the counters are brought up to date at least once per
second or if a certain delta was violated. Drifts are controlled by the
delta configuration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
