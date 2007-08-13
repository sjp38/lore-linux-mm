Date: Tue, 14 Aug 2007 01:08:01 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Message-ID: <20070813230801.GH3406@bingen.suse.de>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie> <200708102013.49170.ak@suse.de> <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com> <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com> <20070813225020.GE3406@bingen.suse.de> <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com> <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 13, 2007 at 03:09:55PM -0700, Christoph Lameter wrote:
> > > > There are still other architectures that use it. Biggest offender
> > > > is s390. I'll leave them to their respective maintainers.
> > > 
> > > IA64 also uses ZONE_DMA to support 32bit controllers. 
> > 
> > ZONE_DMA32 I thought?  That one is not changed.
> 
> x86_64 is the only platforms that uses ZONE_DMA32. Ia64 and other 64 bit 
> platforms use ZONE_DMA for <4GB allocs.

Yes, but ZONE_DMA32 == ZONE_DMA.

Also when the slab users of GFP_DMA are all gone ia64 won't need
the slab support anymore. So either you change your ifdef in slub or 
switch to ZONE_DMA32 for IA64.

The trouble is that this cannot be done globally, at least not
until s390 and a few other architures using GFP_DMA with slab
are all converted.

> I think s/ZONE_DMA32/ZONE_DMA would restore the one DMA zone thing which 
> is good. We could drop all ZONE_DMA32 stuff that is only needed by a 
> single arch.

But it's not quite the same: GFP_DMA32 has no explicit slab support.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
