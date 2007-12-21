Date: Fri, 21 Dec 2007 13:41:38 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB
In-Reply-To: <476B122E.7010108@hp.com>
Message-ID: <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com>
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com>
 <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Seger <Mark.Seger@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Dec 2007, Mark Seger wrote:

> I did some preliminary prototyping and I guess I'm not sure of the math.  If I
> understand what you're saying, an object has a particular size, but given the
> fact that you may need alignment, the true size is really the slab size, and
> the difference is the overhead.  What I don't understand is how to calculate
> how much memory a particular slab takes up.  If the slabsize is really the

If you want the use in terms of pages allocated from the page allocator 
then you do

slabs << order

If you want to use in actual bytes in allocated objects by the user of 
a slab cache then you can do

objects * obj_size

> this IS close enough?  If so, what's the significance of the number of slabs?

Its the amount of pages that were taken from the page allocator.

> Would I divide the 15997K by the number of slabs to find out how big a single
> slab is?  I would have thought that's what the slab_size is but clearly it
> isn't.

The size of a single slab that contains multiple objects is

PAGE_SIZE << order

> 49 N0=19 N1=30
> 
> which I'm guessing may mean 19 objects are allocated to socket 0 and 30 to
> socket 1?  this is a dual-core, dual-socket system.

Right. There are 49 objects in use. 19 of those are on node 0 and 30 on 
node 0. The Nx values only show up on NUMA systems otherwise this will be 
omitted.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
