Date: Thu, 2 Aug 2007 09:36:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-Id: <20070802093623.05dfd39e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1185994779.5059.87.camel@localhost>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	<20070725111646.GA9098@skynet.ie>
	<Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	<20070726132336.GA18825@skynet.ie>
	<Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	<20070726225920.GA10225@skynet.ie>
	<1185994779.5059.87.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@skynet.ie>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 01 Aug 2007 14:59:39 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Kame-san's patch to just exclude the DMA zones from the zonelists is looking
> better--better than changing zonelist order when zone_movable is populated!
> 

I'm now considering setting "lowmem_reserve_ratio" to appropriate value can
help node-order case. (Many cutomer uses the default (in RHEL4 = 0) and saw
troubles.). Is it not enough ?

Thanks,
-Kame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
