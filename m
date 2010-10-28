Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E3AC6B00C1
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 11:12:39 -0400 (EDT)
Date: Thu, 28 Oct 2010 17:12:01 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim
 condition
Message-ID: <20101028151201.GN29304@random.random>
References: <20101027171643.GA4896@csn.ul.ie>
 <20101027180333.GE29304@random.random>
 <20101028162522.B0B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101028162522.B0B5.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 05:00:57PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > My tree uses compaction in a fine way inside kswapd too and tons of
> > systems are running without lumpy and floods of order 9 allocations
> > with only compaction (in direct reclaim and kswapd) without the
> > slighest problem. Furthermore I extended compaction for all
> > allocations not just that PAGE_ALLOC_COSTLY_ORDER (maybe I already
> > removed all PAGE_ALLOC_COSTLY_ORDER checks?). There's no good reason
> > not to use compaction for every allocation including 1,2,3, and things
> > works fine this way.
> 
> Interesting. I parsed this you have compaction improvement. If so,
> can you please post them? Generically, 1) improve the feature 2) remove
> unused one is safety order. In the other hand, reverse order seems to has
> regression risk.

THP is way higher priority than the compaction improvements, so the
compaction improvements are not at the top of the queue:

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commitdiff;h=d8f02410d718725a7daaf192af33abc41dcfae16;hp=39c4a61fedc5f5bf0c95a60483ac0acea1a9a757

At the top of the queue there is the lumpy_reclaim removal as that's
higher priority than THP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
