Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6326B0092
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 04:56:40 -0500 (EST)
Date: Mon, 29 Nov 2010 09:56:19 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
	threshold when memory is low
Message-ID: <20101129095618.GB13268@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie> <1288169256-7174-2-git-send-email-mel@csn.ul.ie> <20101126160619.GP22651@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101126160619.GP22651@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 26, 2010 at 11:06:19AM -0500, Kyle McMartin wrote:
> On Wed, Oct 27, 2010 at 09:47:35AM +0100, Mel Gorman wrote:
> ><snip>
> > To ensure that kswapd wakes up, a safe version of zone_watermark_ok()
> > is introduced that takes a more accurate reading of NR_FREE_PAGES when
> > called from wakeup_kswapd, when deciding whether it is really safe to go
> > back to sleep in sleeping_prematurely() and when deciding if a zone is
> > really balanced or not in balance_pgdat(). We are still using an expensive
> > function but limiting how often it is called.
> ><snip>
> > Reported-by: Shaohua Li <shaohua.li@intel.com>
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Hi Mel,
> 
> I notice these aren't flagged for stable, should they be? (They fairly
> trivially apply and compile on 2.6.36 barring the trace_ points which
> changed.)

They were not flagged for stable because they were performance rather than
function bugs that affected a limited number of machines. Should that decision
be revisited?

> I've got a few bug reports against .36/.37 where kswapd has
> been sleeping for 60s+.
> 

I do not believe these patches would affect kswapd sleeping for 60s.

> I built them some kernels with these patches, but haven't heard back yet
> as to whether it fixes things for them.
> 
> Thanks for any insight,

Can you point me at a relevant bugzilla entry or forward me the bug report
and I'll take a look?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
