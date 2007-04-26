Subject: Re: [PATCH] change global zonelist order on NUMA v3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0704260904190.1655@schroedinger.engr.sgi.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
	 <200704261147.44413.ak@suse.de>
	 <20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070426195348.6a4e5652.kamezawa.hiroyu@jp.fujitsu.com>
	 <1177603203.5705.36.camel@localhost>
	 <Pine.LNX.4.64.0704260904190.1655@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 26 Apr 2007 12:29:22 -0400
Message-Id: <1177604962.5705.55.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-26 at 09:06 -0700, Christoph Lameter wrote:
> Hmmmm... One additional easy way to fix this would be to create a DMA 
> node and place it very distant to other nodes. This would make it a 
> precious system resource that is only used for
> 
> 1. GFP_DMA allocations
> 
> 2. If the memory on the other nodes is exhausted.
> 

This would solve the problem for "100% CLM" configurations where the
only thing in the interleaved pseudo-node is DMA zone.  However, we can
configure any %-age of CLM between 0% [fully interleaved, pseudo-SMP]
and "100%" [which is not really, as I've mentioned].  Interestingly,
older revs of our firmware set the SLIT distance for the interleaved
pseudo-node to 255 [or such], so it was always last.  Then someone
decided that the interleaved node was effectively closer than other
nodes...

I have been considering an HP-platform-specific boot option [handled by
a new ia64 machine vec op] to re-distance the interleaved node, but for
other platforms, such as Kame's, I think we still need the ability to
move the DMA zones last in the Normal zone lists.  Or, exclude them
altogether?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
