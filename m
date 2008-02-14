Date: Thu, 14 Feb 2008 11:06:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 5/5] slub: Large allocs for other slab sizes that do not
 fit in order 0
In-Reply-To: <x46V2RJW.1202973265.1848000.penberg@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802141105010.32613@schroedinger.engr.sgi.com>
References: <x46V2RJW.1202973265.1848000.penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Pekka Enberg wrote:

> On 2/14/2008, "Christoph Lameter" <clameter@sgi.com> wrote:
> > Expand the scheme used for kmalloc-2048 and kmalloc-4096 to all slab
> > caches. That means that kmem_cache_free() must now be able to 
> > handle a fallback object that was allocated from the page allocator. This is
> > touching the fastpath costing us 1/2 % of performance (pretty small
> > so within variance). Kind of hacky though.
> 
> Looks good but are there any numbers that indicate this is an overall win?

I ran tbench tests that shows the performance to be on par as before. Nick 
was concerned about not being able to fallback to order 0 allocs and this 
patch does allow that for most slabs that currently use order 1 allocs. 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
