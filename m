Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DFA9F6B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 11:52:23 -0500 (EST)
Date: Fri, 22 Jan 2010 10:51:35 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
In-Reply-To: <20100122151947.GA3690@random.random>
Message-ID: <alpine.DEB.2.00.1001221008360.4176@router.home>
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Jan 2010, Andrea Arcangeli wrote:

> On Fri, Jan 22, 2010 at 08:46:50AM -0600, Christoph Lameter wrote:
> > Jus thinking about yesterdays fix to page migration:
> >
> > This means that huge pages are unstable right? Kernel code cannot
> > establish a reference to a 2M/4M page and be sure that the page is not
> > broken up due to something in the VM that cannot handle huge pages?
>
> Physically speaking DMA-wise they cannot be broken up, only thing that
> gets broken up is the pmd that instead of mapping the page directly
> starts to map the pte. Nothing changes on the physical side of
> hugepages. khugepaged only collapse pages into hugepages if there are
> no references at all (no gup no nothing) so again no issue DMA-wise.

Reclaim cannot kick out page size pieces of the huge page?

> have irq disabled so the ipi of collapse_huge_page will wait. It's all
> handled transparently by the patch, you won't notice you're dealing
> with hugepage if you're gup user (unless you use gup to migrate pages
> in which case calling split_huge_page is enough like in patch ;).

What if I want to use hugepages for some purpose and I dont want to use
512 pointers to keep track of the individual pieces?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
