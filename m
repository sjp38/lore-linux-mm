Date: Thu, 2 Nov 2006 10:52:12 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061102105212.9bf4579b.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	<20061027190452.6ff86cae.akpm@osdl.org>
	<Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
	<20061027192429.42bb4be4.akpm@osdl.org>
	<Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
	<20061027214324.4f80e992.akpm@osdl.org>
	<Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
	<20061028180402.7c3e6ad8.akpm@osdl.org>
	<Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
	<4544914F.3000502@yahoo.com.au>
	<20061101182605.GC27386@skynet.ie>
	<20061101123451.3fd6cfa4.akpm@osdl.org>
	<Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Nov 2006 22:10:02 +0000 (GMT)
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, 1 Nov 2006, Andrew Morton wrote:
> 
> > On Wed, 1 Nov 2006 18:26:05 +0000
> > mel@skynet.ie (Mel Gorman) wrote:
> >
> >> I never really got this objection. With list-based anti-frag, the
> >> zone-balancing logic remains the same. There are patches from Andy
> >> Whitcroft that reclaims pages in contiguous blocks, but still with the same
> >> zone-ordering. It doesn't affect load balancing between zones as such.
> >
> > I do believe that lumpy-reclaim (initiated by Andy, redone and prototyped
> > by Peter, cruelly abandoned) is a perferable approach to solving the
> > fragmentation approach.
> >
> 
> On it's own lumpy-reclaim or linear-reclaim were not enough to get 
> MAX_ORDER_NR_PAGES blocks of contiguous pages and these were of interest 
> for huge pages although not necessarily of much use to memory hot-unplug. 

I'm interested in lumpy-reclaim as a simple solution to the
e1000-cant-allocate-an-order-2-page problem, rather than for hugepages.

ie: a bugfix, not a feature..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
