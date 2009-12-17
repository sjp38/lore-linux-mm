Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 586376B0093
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 15:11:14 -0500 (EST)
Date: Thu, 17 Dec 2009 14:09:47 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
In-Reply-To: <4B2A8D83.30305@redhat.com>
Message-ID: <alpine.DEB.2.00.0912171402550.4640@router.home>
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Dec 2009, Rik van Riel wrote:

> Christoph Lameter wrote:
> > Would it be possible to start out with a version of huge page support that
> > does not require the complex splitting and joining of huge pages?
> >
> > Without that we would not need additional refcounts.
> >
> > Maybe a patch to allow simply the use of anonymous huge pages without a
> > hugetlbfs mmap in the middle? IMHO its useful even if we cannot swap it
> > out.
>
> Christoph, we need a way to swap these anonymous huge
> pages.  You make it look as if you just want the
> anonymous huge pages and a way to then veto any attempts
> to make them swappable (on account of added overhead).

Can we do this step by step? This splitting thing and its
associated overhead causes me concerns.

> I believe it will be more useful if we figure out a way
> forward together.  Do you have any ideas on how to solve
> the hugepage swapping problem?

Frankly I am not sure that there is a problem. The word swap is mostly
synonymous with "problem". Huge pages are good. I dont think one
needs to necessarily associate something good (huge page) with a known
problem (swap) otherwise the whole may not improve.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
