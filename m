Date: Thu, 26 Jul 2007 19:26:51 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070726182651.GA9618@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070726131539.8a05760f.kamezawa.hiroyu@jp.fujitsu.com> <20070726161652.GA16556@skynet.ie> <Pine.LNX.4.64.0707261100210.2374@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707261100210.2374@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (26/07/07 11:03), Christoph Lameter didst pronounce:
> On Thu, 26 Jul 2007, Mel Gorman wrote:
> 
> > /* policy_zone is the lowest zone index that is present on all nodes */
> > 
> > Right?
> 
> Nope.

I was talking in the context of Kamezawa's patch.

> In a 4 node x86_64 opteron configuration with 8GB memory in 4 2GB 
> chunks you could have
> 
> node 0	ZONE_DMA, ZONE_DMA32   <2GB
> node 1  ZONE_DMA32		<4GB
> node 2	ZONE_NORMAL		<6GB
> node 3  ZONE_NORMAL		<8GB
> 
> So the highest zone gets partitioned off? We only have ZONE_MOVABLE on 
> nodes 2 and 3?
> 

Yes, that is definitly the case with current behaviour.

> There are some other weirdnesses possible with ZONE_MOVABLE on !NUMA.
> 
> 1GB i386 system
> 
> ZONE_DMA
> ZONE_NORMAL <900k
> ZONE_HIGHEMEM	100k size
> 
> ZONE_MOVABLE can then only use 100k?

Correct.

While it would be possible to have highest zone on each node being used
to make up ZONE_MOVABLE, the required code does not exist but could be
supported. Now that the zone is in mainline, the required effort to support
that situation is worth it but it wasn't worth the development effort earlier.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
