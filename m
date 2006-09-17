Date: Sun, 17 Sep 2006 06:01:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Radical idea
Message-ID: <Pine.LNX.4.64.0609170543590.14541@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com
Cc: ak@suse.de, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Sorry about the wrong email address. Bouncing does not do proper outgoing 
address translation.

> Andi wrote:
> > x86-64 can have multiple zones in node > 0 (e.g. node 1 can have both
> > DMA32 and NORMAL) 

>In this case, Christoph, would your radical idea preserve user visible
>node numbers?  In general, the kernels numbering of nodes (as well as
>its numbering of cpus) is exposed to user space in various ways.  What's
>exposed should not change.

It would just add new node numbers for containers and dma zones outside 
of the physical range.

And yes it would only work the DMA32 problems mentioned by Andi could be
addressed. Do we really need DMA32 in modern systems with IOMMUs? Isnt 
this a transitionary problem that will go away?

So lets say we have one of those systems without IOMMU. Then we only have 
a problem for a class of NUMA systems that have:

1. Memory beyond 4GB

and

2. Per node memory less than 4GB. Otherwise DMA32 is only on node 0.

Isnt this a fairly small group of systems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
