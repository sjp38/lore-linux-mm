Date: Sat, 28 Oct 2006 18:04:02 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061028180402.7c3e6ad8.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
	<20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
	<45347288.6040808@yahoo.com.au>
	<Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
	<45360CD7.6060202@yahoo.com.au>
	<20061018123840.a67e6a44.akpm@osdl.org>
	<Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
	<20061026150938.bdf9d812.akpm@osdl.org>
	<Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	<20061027190452.6ff86cae.akpm@osdl.org>
	<Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
	<20061027192429.42bb4be4.akpm@osdl.org>
	<Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
	<20061027214324.4f80e992.akpm@osdl.org>
	<Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Oct 2006 17:48:40 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 27 Oct 2006, Andrew Morton wrote:
> 
> > Right.  We need zones for lots and lots of things.  This all comes back to
> > my main point: the hardwired and magical DMA, DMA32, NORMAL and HIGHMEM
> > zones don't cut it.  We'd be well-served by implementing the core MM as
> > just "one or more zones".  The placement, sizing and *meaning* behind those
> > zones is externally defined.
> 
> We (and I personally with the prezeroing patches) have been down 
> this road several times and did not like what we saw. 

Details?

> > That's all virtual machine stuff, where the "kernel"'s memory is virtual,
> > not physical.
> 
> That is the case on most platforms x86_64, ia64. Kernel memory is movable

It is?

> and the Virtual Iron guys have demonstrated how to do that without
> additional zones.

How?

> > 
> > > > Userspace allocations are reclaimable: pagecache, anonymous memory.  These
> > > > happen to be allocated with __GFP_HIGHMEM set.
> > > 
> > > On certain platforms yes.
> > 
> > On _all_ platforms.  See GFP_HIGHUSER.
> 
> User space allocations are movable already via page migration. 

Of course.

> > > > So right now __GFP_HIGHMEM is an excellent hint telling the page allocator
> > > > that it is safe to satisfy this request from removeable memory.
> 
> For that we would have to have a distinction of removable memory which 
> wont be necessary if we use the existing mappings to move the physical
> location while keeping the virtual addresses.

You're proposing that all kernel memory be virtually mapped?

I've never seen such a proposal nor any implementation.

Or maybe you're referring to something else.  Please let's stop playing
question-and-answer.  Please provide sufficient information so that people
can understand what you're saying.

> > I don't think there's any other (practical) way of implementing hot-unplug.
> 
> Of course there is. As soon as you have virtual mappings its fairly easy 
> to do.
> 
> 1. Migrate all what you can off the memory section that you want to
>    free.
> 
> 2. Use the page table to dynamically remap the leftover pages.

I've never ever seen anyone propose that all kernel memory be virtually
mapped.  I don't know what you're talking about.  Please provide all
details.

> > But hot-unplug is just an example.  My main point here is that it is
> > desirable that we get away from the up-to-four magical hard-wired zones in
> > core MM.
> 
> We have been facing that decision repeatedly and it was pretty clear that 
> there would be significant disadvantages.

Again.  On the whole, that was a pretty useless email.  Please give us
something we can use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
