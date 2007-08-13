Date: Mon, 13 Aug 2007 15:09:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070813225841.GG3406@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <200708102013.49170.ak@suse.de> <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com>
 <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com>
 <20070813225020.GE3406@bingen.suse.de> <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
 <20070813225841.GG3406@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> On Mon, Aug 13, 2007 at 03:00:14PM -0700, Christoph Lameter wrote:
> > You said that ZONE_DMA will still be there right? So the zone will be 
> 
> There will be a (variable sized) dma zone, but not a ZONE_DMA entry in pgdat 
> or in the the fallback lists.

Ahh.. Okay.

> > > There are still other architectures that use it. Biggest offender
> > > is s390. I'll leave them to their respective maintainers.
> > 
> > IA64 also uses ZONE_DMA to support 32bit controllers. 
> 
> ZONE_DMA32 I thought?  That one is not changed.

x86_64 is the only platforms that uses ZONE_DMA32. Ia64 and other 64 bit 
platforms use ZONE_DMA for <4GB allocs.

> > If so then it may be better to drop ZONE_DMA32 and make ZONE_DMA be below 
> > 4GB like other 64bit arches.
> 
> That might be possible as a followup, but would change the driver
> API. Is it worth it? 

It would leave the driver API as is for many arches.

I think s/ZONE_DMA32/ZONE_DMA would restore the one DMA zone thing which 
is good. We could drop all ZONE_DMA32 stuff that is only needed by a 
single arch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
