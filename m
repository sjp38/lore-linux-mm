Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 50E646B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 15:00:42 -0400 (EDT)
Date: Wed, 31 Mar 2010 13:59:44 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #16
In-Reply-To: <20100331164147.GN5825@random.random>
Message-ID: <alpine.DEB.2.00.1003311354590.21554@router.home>
References: <patchbomb.1269887833@v2.random> <20100331141035.523c9285.kamezawa.hiroyu@jp.fujitsu.com> <20100331153339.GK5825@random.random> <alpine.DEB.2.00.1003311102580.17603@router.home> <20100331164147.GN5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Andrea Arcangeli wrote:

> > Large pages would be more independent from the page table structure with
> > the approach that I outlined earlier since you would not have to do these
> > sync tricks.
>
> I was talking about memory compaction. collapse_huge_page will still
> be needed forever regardless of split_huge_page existing or not.

Right but neither function would not be so page table format
dependent as here.

> > There are applications that have benefited for years already from 1G page
> > sizes (available on IA64 f.e.). So why wait?
>
> Because the difficulty on finding hugepages free increases
> exponentially with the order of allocation. Plus increasing MAX_ORDER
> so much would slowdown everything for no gain because we will fail to
> obtain 1G pages freed. The cost of compacting 1G pages also is 512
> times bigger than with regular pages. It's not feasible right now with
> current memory sizes, I just said it's probably better to move to
> PAGE_SIZE 2M instead of extending to 1g pages in a kernel whose
> PAGE_SIZE is 4k.

You would still want 4k pages for small files.

> Last but not the least it can be done but considering I'm abruptly
> failing to merge 35 patches (and surely your comments aren't helping
> in that direction...), it'd be counter-productive to make the core

Well by know you may have realized that I am not too enthusiastic about
the approach. But certainly 2M can be done before 1G support. I was not
suggesting that 1G support is a requirement. However, 1G and 2M
support at the same time would force a cleaner design and maybe get rid
of the page table hackery here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
