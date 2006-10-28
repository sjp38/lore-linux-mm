Date: Fri, 27 Oct 2006 19:31:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061027192429.42bb4be4.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
 <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org>
 <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
 <20061026150938.bdf9d812.akpm@osdl.org> <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2006, Andrew Morton wrote:

> We need some way of preventing unreclaimable kernel memory allocations from
> using certain physical pages.  That means zones.

Well then we may need zones for defragmentation and zeroed pages as well 
etc etc. The problem is that such things make the VM much more 
complex and not simpler and faster.

> > Memory hot unplug 
> > seems to have been dropped in favor of baloons.
> 
> Has it?  I don't recall seeing a vague proposal, let alone an implementation?

That is the impression that I got at the OLS. There were lots of talks 
about baloons approaches.

> Userspace allocations are reclaimable: pagecache, anonymous memory.  These
> happen to be allocated with __GFP_HIGHMEM set.

On certain platforms yes.

> So right now __GFP_HIGHMEM is an excellent hint telling the page allocator
> that it is safe to satisfy this request from removeable memory.

OK this works on i386 but most other platforms wont have a highmem 
zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
