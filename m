Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C40C56B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:24:57 -0400 (EDT)
Date: Wed, 31 Mar 2010 11:24:02 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #16
In-Reply-To: <20100331153339.GK5825@random.random>
Message-ID: <alpine.DEB.2.00.1003311102580.17603@router.home>
References: <patchbomb.1269887833@v2.random> <20100331141035.523c9285.kamezawa.hiroyu@jp.fujitsu.com> <20100331153339.GK5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Andrea Arcangeli wrote:

> > I'm sorry if you answered someone already.
>
> The generic archs without pmd approach can't mix hugepages and regular
> pages in the same vma, so they can't provide graceful fallback and
> never fail an allocation despite there is pleny of memory free which
> is one critical fundamental point in the design (and later collapse
> those with khugepaged which also can run memory compaction
> asynchronously in the background and not synchronously during page
> fault which would be entirely worthless for short lived allocations).

Large pages would be more independent from the page table structure with
the approach that I outlined earlier since you would not have to do these
sync tricks.

> About the HPAGE_PMD_ prefix it's not only HPAGE_ like I did initially,
> in case we later decide to split/collapse 1G pages too but frankly I
> think by the time memory size doubles 512 times across the board (to
> make 1G pages a not totally wasted effort to implement in the
> transparent hugepage support) we'd better move the PAGE_SIZE to 2M and
> stick to the HPAGE_PMD_ again.

There are applications that have benefited for years already from 1G page
sizes (available on IA64 f.e.). So why wait?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
