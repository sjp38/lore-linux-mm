Date: Thu, 14 Feb 2008 11:04:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/5] slub: Use __GFP_MOVABLE for slabs of HPAGE_SIZE
In-Reply-To: <pPfYnrlM.1202972824.1894450.penberg@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802141103320.32613@schroedinger.engr.sgi.com>
References: <pPfYnrlM.1202972824.1894450.penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Pekka Enberg wrote:

> > This will make a system that was booted with
> > 
> > 	slub_min_order = 9
> > 
> > not have any reclaimable slab allocations anymore. All slab allocations
> > will be of type MOVABLE (although they are not movable like huge pages
> > are also not movable). This means that we only have MOVABLE and 
> > UNMOVABLE sections of memory which reduces the types of sections 
> > and therefore the danger of fragmenting memory.
> 
> Why does slub_min_order=9 matter? I suppose this is fixing some other
> real bug?

Because some people run slub with huge page allocations. It makes a lot of 
sense on systems that have more than 4 - 8G of RAM per cpu. The 2M pages 
for 100 slab caches (usually we have only 70) take 200M which is just a 
small fraction of the memory for one processor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
