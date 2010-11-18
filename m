Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E0FF66B0088
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:23:05 -0500 (EST)
Date: Thu, 18 Nov 2010 16:22:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 55 of 66] select CONFIG_COMPACTION if
	TRANSPARENT_HUGEPAGE enabled
Message-ID: <20101118162245.GE8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <89a62752012298bb500c.1288798110@v2.random> <20101109151756.BC7B.A69D9226@jp.fujitsu.com> <20101109211145.GB6809@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101109211145.GB6809@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 10:11:45PM +0100, Andrea Arcangeli wrote:
> On Tue, Nov 09, 2010 at 03:20:33PM +0900, KOSAKI Motohiro wrote:
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > With transparent hugepage support we need compaction for the "defrag" sysfs
> > > controls to be effective.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > ---
> > > 
> > > diff --git a/mm/Kconfig b/mm/Kconfig
> > > --- a/mm/Kconfig
> > > +++ b/mm/Kconfig
> > > @@ -305,6 +305,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
> > >  config TRANSPARENT_HUGEPAGE
> > >  	bool "Transparent Hugepage Support"
> > >  	depends on X86 && MMU
> > > +	select COMPACTION
> > >  	help
> > >  	  Transparent Hugepages allows the kernel to use huge pages and
> > >  	  huge tlb transparently to the applications whenever possible.
> > 
> > I dislike this. THP and compaction are completely orthogonal. I think 
> > you are talking only your performance recommendation. I mean I dislike
> > Kconfig 'select' hell and I hope every developers try to avoid it as 
> > far as possible.
> 
> At the moment THP hangs the system if COMPACTION isn't selected

Just to confirm - by hang, you mean grinds to a slow pace as opposed to
coming to a complete stop and having to restart?

If so then

Acked-by: Mel Gorman <mel@csn.ul.ie>

> (please try yourself if you don't believe), as without COMPACTION
> lumpy reclaim wouldn't be entirely disabled. So at the moment it's not
> orthogonal. When lumpy will be removed from the VM (like I tried
> multiple times to achieve) I can remove the select COMPACTION in
> theory, but then 99% of THP users would be still doing a mistake in
> disabling compaction, even if the mistake won't return in fatal
> runtime but just slightly degraded performance.
> 

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
