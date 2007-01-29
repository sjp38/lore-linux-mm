Date: Mon, 29 Jan 2007 08:56:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/8] Use ZVCs for accurate writeback ratio determination
In-Reply-To: <45BD5E8D.6080206@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701290854590.28200@schroedinger.engr.sgi.com>
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
 <45B9F26D.5090107@yahoo.com.au> <Pine.LNX.4.64.0701260745030.6141@schroedinger.engr.sgi.com>
 <45BD5E8D.6080206@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Nick Piggin wrote:

> > We could add NR_SLAB_RECLAIMABLE if that is a factor. However, these pages
> > cannot be dirtied. They may be reclaimed yes and then pages may become
> > available again. However, that is a difficult process without
> > slab defrag. Are you sure that these are significant?
> 
> I think so. I have seen systems that get very full of dcache/icache, and
> little to no pagecache. In that case it makes no sense to limit dirty
> pages to a potentially small amount.
> 
> Slab reclaim does work. It may not be perfect, but I don't think that
> should spill over into dirty page calculations. If anything we need to
> improve slab reclaimability estimates for that.

How about adding NR_SLAB_RECLAIMABLE / 2 to take the reclaim problems into 
account that may lead to many pages not be recoverable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
