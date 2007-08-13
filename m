Date: Mon, 13 Aug 2007 15:22:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070813230801.GH3406@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708131518320.28626@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <200708102013.49170.ak@suse.de> <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com>
 <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com>
 <20070813225020.GE3406@bingen.suse.de> <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
 <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
 <20070813230801.GH3406@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> > x86_64 is the only platforms that uses ZONE_DMA32. Ia64 and other 64 bit 
> > platforms use ZONE_DMA for <4GB allocs.
> 
> Yes, but ZONE_DMA32 == ZONE_DMA.

I am not sure what you mean by that. Ia64 ZONE_DMA == x86_84 ZONE_DMA32?

> Also when the slab users of GFP_DMA are all gone ia64 won't need
> the slab support anymore. So either you change your ifdef in slub or 
> switch to ZONE_DMA32 for IA64.

If you have gotten rid of all slab users of GFP_DMA (and also all arch 
uses of it) then we can drop the code in SLAB.

> The trouble is that this cannot be done globally, at least not
> until s390 and a few other architures using GFP_DMA with slab
> are all converted.

The s390 arch code still contains GFP_DMA uses? No drivers elsewhere 
still use GFP_DMA?

> 
> > I think s/ZONE_DMA32/ZONE_DMA would restore the one DMA zone thing which 
> > is good. We could drop all ZONE_DMA32 stuff that is only needed by a 
> > single arch.
> 
> But it's not quite the same: GFP_DMA32 has no explicit slab support.

Right. So we could

1. Drop sl?b support for GFP_DMA.

2. Drop GFP_DMA32 support.

Then we only allow page allocator allocs using GFP_DMA? That may be the 
least invasive for arch code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
