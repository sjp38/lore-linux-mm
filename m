Date: Tue, 14 Mar 2006 07:36:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 1/8 migrate task memory
 with default policy
In-Reply-To: <1142347567.5235.18.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0603140734060.17761@schroedinger.engr.sgi.com>
References: <1142019479.5204.15.camel@localhost.localdomain>
 <Pine.LNX.4.64.0603131547020.13713@schroedinger.engr.sgi.com>
 <1142347567.5235.18.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Mar 2006, Lee Schermerhorn wrote:

> > Could you add some special casing instead to migrate_to_node and/or 
> > check_range?
> 
> I think this could be done.  Don't know whether the results would be
> "pretty" or not.

Make it as pretty as possible.

> Currently, you'll note that I'm calling check_range for one vma at a
> time.  I'm not sure this is a good idea.  It probably adds overhead
> revisiting upper level page table pages many times.  But, I want to
> compare different approaches.  If I use migrate_to_node() and it's call
> to check_range(), I would have to have something like the above logic to
> do the per vma stuff.   But, why per vma?  I agree it doesn't make a lot
> of sense for the kernel build workload.  I find very few eligible pages
> to migrate, so even if I scanned the entire mm at once, the resulting
> page list would be very small.  However, I was concerned about tying up
> a large number of pages, isolated from the LRU, for applications with
> larger footprints.  I'm also going to experiment with more agressive

Well if you just find a few pages to migrate then the pages isolated from 
the LRU will also be few.

> migration--i.e., selecting pages with >1 map counts.  This may result in
> larger numbers of pages migrating.

Yes and doing so may stall the concurrent compiler passes.

> But, I have thought about adding internal flags to steer different paths
> through migrate_to_node() and check_range().  If we ever get serious
> about including an automigration mechanism like this, I'll go ahead and
> take a look at it.

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
