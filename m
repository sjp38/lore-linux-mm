From: Andi Kleen <ak@suse.de>
Subject: Re: Radical idea
Date: Sun, 17 Sep 2006 20:13:27 +0200
References: <Pine.LNX.4.64.0609170543590.14541@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609170543590.14541@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609172013.27095.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: pj@sgi.com, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> 
> And yes it would only work the DMA32 problems mentioned by Andi could be
> addressed. Do we really need DMA32 in modern systems with IOMMUs?

We do.

In fact we still need DMA-without-32 on most systems (after all most users
still want to use their floppy occasionally and it is needed for a few other
devices too)

> Isnt this a transitionary problem that will go away?

Not any time soon.

> So lets say we have one of those systems without IOMMU. Then we only have 
> a problem for a class of NUMA systems that have:
> 
> 1. Memory beyond 4GB
> 
> and
> 
> 2. Per node memory less than 4GB. Otherwise DMA32 is only on node 0.
> 
> Isnt this a fairly small group of systems?

I don't think so. e.g. a lot of quad opteron configurations come with 1 or 2GB per
socket (= node) 

Anyways, even if it was uncommon we couldn't just break it. So i'm not sure what
the point of your "popularity contest" is?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
