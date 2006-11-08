Date: Wed, 8 Nov 2006 09:29:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061108092957.d9f7fc74.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0611071756050.11212@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
	<454A2CE5.6080003@shadowen.org>
	<Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
	<Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
	<Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
	<Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
	<Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
	<Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611071629040.11212@skynet.skynet.ie>
	<Pine.LNX.4.64.0611070947100.3791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611071756050.11212@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, apw@shadowen.org, akpm@osdl.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Tue, 7 Nov 2006 18:14:31 +0000 (GMT)
Mel Gorman <mel@csn.ul.ie> wrote:
> > Could it be that the only reason that the current approach works is that
> > we have not tested with an application that behaves this way?
> >
> 
> Probably. The applications I currently test are not mlocking. The tests 
> currently run workloads that are known to leave the system in a fragmented 
> state when they complete. In this situation, higher-order allocations fail 
> even when nothing is running and there are no mlocked() pages on the 
> standard allocator.
> 
In these days, I've struggled with crashdump from a user to investigate the reason
of oom-kill. At last, the reason was most of 2G bytes ZONE_DMA pages were
mlocked(). Sigh....
I wonder we can use migration of MOVABLE pages for zone balancing in future.
(maybe complicated but...)

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
