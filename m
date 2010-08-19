Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 968DA6B02C6
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 15:03:34 -0400 (EDT)
Date: Thu, 19 Aug 2010 14:03:42 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Over-eager swapping
In-Reply-To: <20100819102055.GK2370@arachsys.com>
Message-ID: <alpine.DEB.2.00.1008191402050.1839@router.home>
References: <20100804032400.GA14141@localhost> <20100804095811.GC2326@arachsys.com> <20100804114933.GA13527@localhost> <20100804120430.GB23551@arachsys.com> <20100818143801.GA9086@localhost> <20100818144655.GX2370@arachsys.com> <20100818152103.GA11268@localhost>
 <1282147034.77481.33.camel@useless.localdomain> <20100818155825.GA2370@arachsys.com> <alpine.DEB.2.00.1008181112510.6294@router.home> <20100819102055.GK2370@arachsys.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, Chris Webb wrote:

> I tried this on a handful of the problem hosts before re-adding their swap.
> One of them now runs without dipping into swap. The other three I tried had
> the same behaviour of sitting at zero swap usage for a while, before
> suddenly spiralling up with %wait going through the roof. I had to swapoff
> on them to bring them back into a sane state. So it looks like it helps a
> bit, but doesn't cure the problem.
>
> I could definitely believe an explanation that we're swapping in preference
> to allocating remote zone pages somehow, given the imbalance in free memory
> between the nodes which we saw. However, I read the documentation for
> vm.zone_reclaim_mode, which suggests to me that when it was set to zero,
> pages from remote zones should be allocated automatically in preference to
> swap given that zone_reclaim_mode & 4 == 0?

If zone reclaim is off then pages from other nodes will be allocated if a
node is filled up with page cache.

zone reclaim typically only evicts clean page cache pages in order to keep
the additional overhead down. Enabling swapping allows a more aggressive
form of recovering memory in preference of going off line.

The VM should work fine even without zone reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
