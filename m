Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D12996B0101
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 22:23:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T2NASG029066
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 29 Oct 2010 11:23:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0344045DE51
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:23:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3ADC45DE53
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:23:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 87B4FE18006
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:23:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15863E08005
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:23:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim condition
In-Reply-To: <20101028151201.GN29304@random.random>
References: <20101028162522.B0B5.A69D9226@jp.fujitsu.com> <20101028151201.GN29304@random.random>
Message-Id: <20101029104314.B0C0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 29 Oct 2010 11:23:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Oct 28, 2010 at 05:00:57PM +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > My tree uses compaction in a fine way inside kswapd too and tons of
> > > systems are running without lumpy and floods of order 9 allocations
> > > with only compaction (in direct reclaim and kswapd) without the
> > > slighest problem. Furthermore I extended compaction for all
> > > allocations not just that PAGE_ALLOC_COSTLY_ORDER (maybe I already
> > > removed all PAGE_ALLOC_COSTLY_ORDER checks?). There's no good reason
> > > not to use compaction for every allocation including 1,2,3, and things
> > > works fine this way.
> > 
> > Interesting. I parsed this you have compaction improvement. If so,
> > can you please post them? Generically, 1) improve the feature 2) remove
> > unused one is safety order. In the other hand, reverse order seems to has
> > regression risk.
> 
> THP is way higher priority than the compaction improvements, so the
> compaction improvements are not at the top of the queue:
> 
> http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog
> 
> http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commitdiff;h=d8f02410d718725a7daaf192af33abc41dcfae16;hp=39c4a61fedc5f5bf0c95a60483ac0acea1a9a757
> 
> At the top of the queue there is the lumpy_reclaim removal as that's
> higher priority than THP.

Umm... 

If THP vs lumpy confliction is most big matter, I'd prefer automatical 
lumpy disabling when THP enabled rather than completely removing. It is lower risk.
And, After finish to improve compaction, I expect we will be able to discuss
remove thing. 

If my parse is correct, You have tested "improved-compaction + no-lumpy + THP"
combination, but nobody have tested "current-compaction + no-lumpy". 
IOW, I only say I dislike a regression.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
