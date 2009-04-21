Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A3DF6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 03:39:30 -0400 (EDT)
Received: by ti-out-0910.google.com with SMTP id a21so1541704tia.8
        for <linux-mm@kvack.org>; Tue, 21 Apr 2009 00:40:05 -0700 (PDT)
Date: Tue, 21 Apr 2009 16:39:54 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] low order lumpy reclaim also should use
 PAGEOUT_IO_SYNC.
Message-Id: <20090421163954.eabf5543.minchan.kim@barrios-desktop>
In-Reply-To: <20090421161829.F139.A69D9226@jp.fujitsu.com>
References: <20090421142056.F127.A69D9226@jp.fujitsu.com>
	<20090421161219.e13a928d.minchan.kim@barrios-desktop>
	<20090421161829.F139.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 16:21:18 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Hi, Kosaki-san. 
> > 
> > On Tue, 21 Apr 2009 14:22:27 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Subject: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.
> > > 
> > > commit 33c120ed2843090e2bd316de1588b8bf8b96cbde (more aggressively use lumpy reclaim)
> > > change lumpy reclaim using condition. but it isn't enough change.
> > > 
> > > lumpy reclaim don't only mean isolate neighber page, but also do pageout as synchronous.
> > > this patch does it.
> > 
> > I agree. 
> > 
> > Andi added  synchronous lumpy reclaim with c661b078fd62abe06fd11fab4ac5e4eeafe26b6d.
> > At that time, lumpy reclaim is not agressive. 
> > His intension is just for high-order users.(above PAGE_ALLOC_COSTLY_ORDER). 
> > 
> > After some time, Rik added aggressive lumpy reclaim with 33c120ed2843090e2bd316de1588b8bf8b96cbde.
> > His intension is that do lumpy reclaim when high-order users and trouble getting a small set of contiguous pages. 
> > 
> > So we also have to add synchronous pageout for small set of contiguous pages. 
> > Nice catch!. 
> > 
> > Reviewed-by: Minchan Kim <Minchan.kim@gmail.com>
> > 
> > BTW, Do you have any number ? 
> 
> No.
> 
> Actually, this logic only run when system is strongly memory stavation
> or fragment. not normal case.
> 
> At that time, another slowdown thing hide synchronous reclaim latency, I think.
> 

Yes. I think it's hard measure, too. 
I was just out of curiosity if server guy have a any benchmark method. ;-)


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
