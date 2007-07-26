Date: Thu, 26 Jul 2007 11:03:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <20070726161652.GA16556@skynet.ie>
Message-ID: <Pine.LNX.4.64.0707261100210.2374@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
 <20070726131539.8a05760f.kamezawa.hiroyu@jp.fujitsu.com> <20070726161652.GA16556@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007, Mel Gorman wrote:

> /* policy_zone is the lowest zone index that is present on all nodes */
> 
> Right?

Nope. In a 4 node x86_64 opteron configuration with 8GB memory in 4 2GB 
chunks you could have

node 0	ZONE_DMA, ZONE_DMA32   <2GB
node 1  ZONE_DMA32		<4GB
node 2	ZONE_NORMAL		<6GB
node 3  ZONE_NORMAL		<8GB

So the highest zone gets partitioned off? We only have ZONE_MOVABLE on 
nodes 2 and 3?

There are some other weirdnesses possible with ZONE_MOVABLE on !NUMA.

1GB i386 system

ZONE_DMA
ZONE_NORMAL <900k
ZONE_HIGHEMEM	100k size


ZONE_MOVABLE can then only use 100k?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
