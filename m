Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 257386B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 03:21:03 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L7LKNS019108
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 16:21:20 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 15D0745DE54
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 16:21:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E01BD45DE51
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 16:21:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ADF61E08004
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 16:21:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E26D1DB8060
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 16:21:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.
In-Reply-To: <20090421161219.e13a928d.minchan.kim@barrios-desktop>
References: <20090421142056.F127.A69D9226@jp.fujitsu.com> <20090421161219.e13a928d.minchan.kim@barrios-desktop>
Message-Id: <20090421161829.F139.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 16:21:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> Hi, Kosaki-san. 
> 
> On Tue, 21 Apr 2009 14:22:27 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Subject: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.
> > 
> > commit 33c120ed2843090e2bd316de1588b8bf8b96cbde (more aggressively use lumpy reclaim)
> > change lumpy reclaim using condition. but it isn't enough change.
> > 
> > lumpy reclaim don't only mean isolate neighber page, but also do pageout as synchronous.
> > this patch does it.
> 
> I agree. 
> 
> Andi added  synchronous lumpy reclaim with c661b078fd62abe06fd11fab4ac5e4eeafe26b6d.
> At that time, lumpy reclaim is not agressive. 
> His intension is just for high-order users.(above PAGE_ALLOC_COSTLY_ORDER). 
> 
> After some time, Rik added aggressive lumpy reclaim with 33c120ed2843090e2bd316de1588b8bf8b96cbde.
> His intension is that do lumpy reclaim when high-order users and trouble getting a small set of contiguous pages. 
> 
> So we also have to add synchronous pageout for small set of contiguous pages. 
> Nice catch!. 
> 
> Reviewed-by: Minchan Kim <Minchan.kim@gmail.com>
> 
> BTW, Do you have any number ? 

No.

Actually, this logic only run when system is strongly memory stavation
or fragment. not normal case.

At that time, another slowdown thing hide synchronous reclaim latency, I think.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
