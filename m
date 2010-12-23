Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AEE706B0088
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 19:00:55 -0500 (EST)
Date: Thu, 23 Dec 2010 18:00:27 -0500
From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-ID: <20101223230027.GJ15129@bombadil.infradead.org>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
 <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
 <20101126160619.GP22651@bombadil.infradead.org>
 <20101129095618.GB13268@csn.ul.ie>
 <20101129131626.GF15818@bombadil.infradead.org>
 <20101129150824.GF13268@csn.ul.ie>
 <20101129152230.GH15818@bombadil.infradead.org>
 <20101129155801.GG13268@csn.ul.ie>
 <alpine.DEB.2.00.1012231413560.2116@chino.kir.corp.google.com>
 <20101223143521.f94a5106.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101223143521.f94a5106.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Greg Kroah-Hartman <gregkh@suse.de>, Kyle McMartin <kyle@mcmartin.ca>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 02:35:21PM -0800, Andrew Morton wrote:
> > > Andrew, this patch was a performance fix but is a report saying that it
> > > fixes a functional regression in Fedora enough to push a patch torwards
> > > stable even though an explanation as to *why* it fixes the problem is missing?
> > We had to pull aa454840 "mm: page allocator: calculate a better estimate 
> > of NR_FREE_PAGES when memory is low and kswapd is awake" from 2.6.36 
> > internally because tests showed that it would cause the machine to stall 
> > as the result of heavy kswapd activity.  I merged it back with this fix as 
> > it is pending in the -mm tree and it solves the issue we were seeing, so I 
> > definitely think this should be pushed to -stable (and I would seriously 
> > consider it for 2.6.37 inclusion even at this late date).
> 
> How's about I send
> mm-page-allocator-adjust-the-per-cpu-counter-threshold-when-memory-is-low.patch
> in for 2.6.38 and tag it for backporting into 2.6.37.1 and 2.6.36.x? 
> That way it'll get a bit of 2.6.38-rc testing before being merged into
> 2.6.37.x.
> 

That sounds fine to me. (Thanks very much for the update, David!) I
don't mind carrying a few extra patches here and there in Fedora to get
them some exposure if they're low risk... I've been carrying Mel's
patches for a month or so now and it hasn't turned up any obvious
problems in testing.

regards, Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
