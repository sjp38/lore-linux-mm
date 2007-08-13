Date: Tue, 14 Aug 2007 00:58:41 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Message-ID: <20070813225841.GG3406@bingen.suse.de>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie> <200708102013.49170.ak@suse.de> <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com> <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com> <20070813225020.GE3406@bingen.suse.de> <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 13, 2007 at 03:00:14PM -0700, Christoph Lameter wrote:
> You said that ZONE_DMA will still be there right? So the zone will be 

There will be a (variable sized) dma zone, but not a ZONE_DMA entry in pgdat 
or in the the fallback lists.

> 
> > There are still other architectures that use it. Biggest offender
> > is s390. I'll leave them to their respective maintainers.
> 
> IA64 also uses ZONE_DMA to support 32bit controllers. 

ZONE_DMA32 I thought?  That one is not changed.

> 
> So I think we can only get rid of ZONE_DMA in its 16MB incarnation for 
> i386 and x86_64.

Correct. 

> 
> But you will be keeping ZONE_DMA32?

Yes.

> If so then it may be better to drop ZONE_DMA32 and make ZONE_DMA be below 
> 4GB like other 64bit arches.

That might be possible as a followup, but would change the driver
API. Is it worth it? 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
