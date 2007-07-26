Date: Thu, 26 Jul 2007 16:41:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-Id: <20070726164137.4349eeb6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0707252150001.15620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	<20070725111646.GA9098@skynet.ie>
	<Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	<20070726131539.8a05760f.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707252150001.15620@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007 21:53:32 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 26 Jul 2007, KAMEZAWA Hiroyuki wrote:
> 
> > Hmm,  How about following patch ? (not tested, just an idea).
> > I'm sorry if I misunderstand concept ot policy_zone.
> 
> Maybe we should get rid of policy zone completely? There are only a few 
> lower zones on a NUMA machine anyways and if the filtering in 
> __alloc_pages does the trick then we could simply generate lists will
> all zones in build_bindzonelist.
> 
> The main dividing line may be if zones are available on all (memory) 
> nodes. If they are only available on a single nodes (like DMA or DMA32) 
> then policies must be disregarded if the alloc would otherwise not be 
> possible.
> 

IMHO, when using customized zonelists, zonelists[MAX_NR_ZONES] should be
prepared for all gfp_zone(GFP_xxx). But zonlists[] can be very big.

Another thinking, currnet MBIND uses pages from lower nodes, (nodes have lower ids.)
even if the node is far. And all process which uses MBIND have the same tendency.

I'd like to vote for implementing node_mask check in alloc_pages, but doesn't have
good idea to implement it in efficient manner on 1024-nodes server...

like, alloc_page_mask(gftp_t gftp, int order, nodemask_t mask);


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
