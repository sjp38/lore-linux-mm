Date: Wed, 25 Jul 2007 21:53:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <20070726131539.8a05760f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0707252150001.15620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
 <20070726131539.8a05760f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007, KAMEZAWA Hiroyuki wrote:

> Hmm,  How about following patch ? (not tested, just an idea).
> I'm sorry if I misunderstand concept ot policy_zone.

Maybe we should get rid of policy zone completely? There are only a few 
lower zones on a NUMA machine anyways and if the filtering in 
__alloc_pages does the trick then we could simply generate lists will
all zones in build_bindzonelist.

The main dividing line may be if zones are available on all (memory) 
nodes. If they are only available on a single nodes (like DMA or DMA32) 
then policies must be disregarded if the alloc would otherwise not be 
possible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
