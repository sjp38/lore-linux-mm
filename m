Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D5E026B00AF
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 12:26:28 -0500 (EST)
Date: Tue, 26 Jan 2010 17:26:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126172613.GD16468@csn.ul.ie>
References: <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home> <4B5E3CC0.2060006@redhat.com> <alpine.DEB.2.00.1001260947580.23549@router.home> <20100126161625.GO30452@random.random> <20100126164230.GC16468@csn.ul.ie> <20100126165254.GR30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100126165254.GR30452@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 05:52:55PM +0100, Andrea Arcangeli wrote:
> > hugetlbfs may be not be ideal, but it's not quite as catastrophic as
> > commonly believed either.
> 
> I want 100% of userbase to take advantage of it, hugetlbfs isn't even
> mounted by default... and there is no way to use libhugetlbfs by
> default.
> 
> I think hugetlbfs is fine for a niche of users (for those power users
> kernel hackers and huge DBMS it may also be better than transparent
> hugepage and they should keep using it!!! thanks to being able to
> reserve pages at boot), but for the 99% of userbase it's exactly as
> catastrophic as commonly believed. Otherwise I am 100% sure that I
> wouldn't be the first one on linux to decrease the tlb misses with 2M

You're not, I beat you to it a long time ago. In fact, I just watched a dumb
hit smack into a treadmill (feeling badminded) with the browser using huge
pages in the background just to confirm I wasn't imagining it.  Launched with

hugectl --shm --heap epiphany-browser

HugePages_Total:       5
HugePages_Free:        1
HugePages_Rsvd:        1
HugePages_Surp:        5
Hugepagesize:       4096 kB
(Surp implies the huge pages were allocated on demand, not statically)

17:22:01 up 7 days,  1:05, 24 users,  load average: 0.62, 0.30, 0.13

Yes, this is not transparent and it's unlikely that a normal user would go
to the hassle although conceivably a distro could set a launcher to
automtaically try huge pages where available.

I'm just saying that hugetlbfs and the existing utilities are not so bad
as to be slammed. Just because it's possible to do something like this does
not detract from transparent support in any way.

> pages while watching videos on youtube (>60M on hugepages will happen
> with atom netbook). And that's nothing compared to many other
> workloads. Yes not so important for desktop but on server especially
> with EPT/NPT it's a must and hugetlbfs is as catastrophic as on
> "default desktop" in the virtualization cloud.
> 

In virtualisation in particular, the lack of swapping makes hugetlbfs a
no-go in it's current form. No doubt about it and the transparent
support will certainly shine with respect to KVM.

On the flip-side, architecture limitations likely make transparent
support a no-go on IA-64 and very likely PPC64 so it doesn't solve
everything either.

The existing stuff will continue to exist alongside transparent support
because they are ideal in different situations.

FWIW, I'm still reading through the patches and have not spotted anything
new that is problematic but I'm only half-way through. By and large, I'm
pro-the-patches but am somewhat compelled to defend hugetlbfs :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
