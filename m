Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 595F86B0088
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 18:46:15 -0500 (EST)
Date: Thu, 23 Dec 2010 15:17:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-Id: <20101223151746.d67e94bf.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1012231456520.2116@chino.kir.corp.google.com>
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
	<alpine.DEB.2.00.1012231456520.2116@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Greg Kroah-Hartman <gregkh@suse.de>, Kyle McMartin <kyle@mcmartin.ca>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Dec 2010 15:07:02 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 23 Dec 2010, Andrew Morton wrote:
> 
> > > We had to pull aa454840 "mm: page allocator: calculate a better estimate 
> > > of NR_FREE_PAGES when memory is low and kswapd is awake" from 2.6.36 
> > > internally because tests showed that it would cause the machine to stall 
> > > as the result of heavy kswapd activity.  I merged it back with this fix as 
> > > it is pending in the -mm tree and it solves the issue we were seeing, so I 
> > > definitely think this should be pushed to -stable (and I would seriously 
> > > consider it for 2.6.37 inclusion even at this late date).
> > 
> > How's about I send
> > mm-page-allocator-adjust-the-per-cpu-counter-threshold-when-memory-is-low.patch
> > in for 2.6.38 and tag it for backporting into 2.6.37.1 and 2.6.36.x? 
> > That way it'll get a bit of 2.6.38-rc testing before being merged into
> > 2.6.37.x.
> > 
> 
> I don't think anyone would be able to answer that judgment call other than 
> you or Linus, it's a trade-off on whether 2.6.37 should be released with 
> the knowledge that it regresses just like 2.6.36 does (rendering both 
> unusable on some of our machines out of the box) because we're late in the 
> cycle.
> 
> I personally think the testing is already sufficient since it's been 
> sitting in -mm for two months, it's been suggested as stable material by a 
> couple different parties, it was a prerequisite for the transparent 
> hugepage series, and we've tested and merged it as fixing the regression 
> in 2.6.36 (as Fedora has, as far as I know).  We've already merged the fix 
> internally, though, so it's not for selfish reasons :)

Wibble, wobble.  It's good that the patch has been used in RH kernels. 
otoh, the patch is really quite big and the problem was present in
2.6.36 without a lot of complaints and we're very late in -rc and not
many people will be testing over xmas/newyear, and it would be most sad
to put badness into mainline at this time.

So I'm still inclined to go with (discretion > valour).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
