Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l25FKGcs012723
	for <linux-mm@kvack.org>; Mon, 5 Mar 2007 10:20:16 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l25FKGen310348
	for <linux-mm@kvack.org>; Mon, 5 Mar 2007 10:20:16 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l25FKDK4032618
	for <linux-mm@kvack.org>; Mon, 5 Mar 2007 10:20:15 -0500
Message-ID: <45EC352A.7060802@austin.ibm.com>
Date: Mon, 05 Mar 2007 09:20:10 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E8594B.6020904@austin.ibm.com> <20070305032116.GA29678@wotan.suse.de>
In-Reply-To: <20070305032116.GA29678@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, clameter@engr.sgi.com, mingo@elte.hu, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> But if you don't require a lot of higher order allocations anyway, then
> guest fragmentation caused by ballooning doesn't seem like much problem.

If you only need to allocate 1 page size and smaller allocations then no it's not a 
problem.  As soon as you go above that it will be.  You don't need to go all the way 
up to MAX_ORDER size to see an impact, it's just increasingly more severe as you get 
away from 1 page and towards MAX_ORDER.

> 
> If you need higher order allocations, then ballooning is bad because of
> fragmentation, so you need memory unplug, so you need higher order
> allocations. Goto 1.

Yes, it's a closed loop.  But hotplug isn't the only one that needs higher order 
allocations.  In fact it's pretty far down the list.  I look at it like this, a lot 
of users need high order allocations for better performance and things like on-demand 
hugepages.  As a bonus you get memory hot-remove.

> Balooning probably does skew memory management stats and watermarks, but
> that's just because it is implemented as a module. A couple of hooks
> should be enough to allow things to be adjusted?

That is a good idea independent of the current discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
