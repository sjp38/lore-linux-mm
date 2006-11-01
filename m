Date: Wed, 1 Nov 2006 12:34:51 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061101123451.3fd6cfa4.akpm@osdl.org>
In-Reply-To: <20061101182605.GC27386@skynet.ie>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Nov 2006 18:26:05 +0000
mel@skynet.ie (Mel Gorman) wrote:

> I never really got this objection. With list-based anti-frag, the
> zone-balancing logic remains the same. There are patches from Andy
> Whitcroft that reclaims pages in contiguous blocks, but still with the same
> zone-ordering. It doesn't affect load balancing between zones as such.

I do believe that lumpy-reclaim (initiated by Andy, redone and prototyped
by Peter, cruelly abandoned) is a perferable approach to solving the
fragmentation approach.

And with __GFP_EASYRECLAIM (please - I just renamed it ;)) (or using
__GFP_HIGHMEM for the same thing) then some of the core lumpy-reclaim
algorithm can be reused for hot-unplug.

If you want to unplug a range of memory then it has to be in a zone which
is 100% __GFP_EASY_RECLAIM (actually the name is still wrong.  It should
just be __GFP_RECLAIMABLE).

The hot-unplug code will go through those pages and it will, with 100%
reliability, rip those pages out of the kernel via various means.  I think
this can all be done.

And hot-unplug isn't actually the interesting application.  Modern Intel
memory controllers apparently have (or will have) the ability to power down
DIMMs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
