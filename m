Date: Wed, 1 Nov 2006 13:46:04 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061101134604.fe8c89c6.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611011255070.14406@schroedinger.engr.sgi.com>
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
	<Pine.LNX.4.64.0611011255070.14406@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Nov 2006 13:00:55 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 1 Nov 2006, Andrew Morton wrote:
> 
> > And hot-unplug isn't actually the interesting application.  Modern Intel
> > memory controllers apparently have (or will have) the ability to power down
> > DIMMs.
> 
> Plus one would want to be able to move memory out of an area where we may 
> have a bad DIMM. If we monitor soft ECC failures then we could also 
> judge a DIMM to be bad if we have a too high soft failure rate.
> 
> If there is a hard failure and we can recover (page cache page f.e.) 
> then we could preemptively disable the complete DIMM.

Point.

> I still think that we need to generalize the approach to be 
> able to cover as much memory as possible. Remapping can solve some of the 
> issues, for others we could add additional ways to make things movable. 
> F.e. one could make page table pages movable by adding a back pointer to 
> the mm, reclaimable slab pages by adding a move function, driver 
> allocations could have a backpointer to the driver that would be able to 
> move its memory.  Hmm.... Maybe generally a way to provide a 
> function to move data in the page struct for kernel allocations?

Sounds hard.  That's all Version 2 ;)

(For example, I do recall working out that going from a slab-page up to a
buffer_head and then reclaiming that buffer_head is basically impossible
from a locking POV, but I forget the details..)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
