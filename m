Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 125706003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:24:23 -0500 (EST)
Date: Tue, 26 Jan 2010 17:24:19 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126162419.GE6567@basil.fritz.box>
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home> <4B5E3CC0.2060006@redhat.com> <alpine.DEB.2.00.1001260947580.23549@router.home> <20100126161625.GO30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126161625.GO30452@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 05:16:25PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 09:54:59AM -0600, Christoph Lameter wrote:
> > Huge pages are already in use through hugetlbs for such workloads. That
> > works without swap. So why is this suddenly such a must have requirement?
> 
> hugetlbfs is unusable when you're not doing a static alloc for 1 DBMS
> in 1 machine with alloc size set in a config file that will then match
> grub command line.

AFAIK that's not true for 2MB pages after all the enhancements
Andy/Mel/et.al. did to the defragmentation heuristics, assuming
you have enough memory (or define movable zones)

hugetlbfs also does the transparent fallback. It's not pretty,
but it seems to work for a lot of people.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
