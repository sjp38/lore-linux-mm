Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 381E76003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:53:55 -0500 (EST)
Date: Tue, 26 Jan 2010 17:52:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126165254.GR30452@random.random>
References: <patchbomb.1264054824@v2.random>
 <alpine.DEB.2.00.1001220845000.2704@router.home>
 <20100122151947.GA3690@random.random>
 <alpine.DEB.2.00.1001221008360.4176@router.home>
 <20100123175847.GC6494@random.random>
 <alpine.DEB.2.00.1001251529070.5379@router.home>
 <4B5E3CC0.2060006@redhat.com>
 <alpine.DEB.2.00.1001260947580.23549@router.home>
 <20100126161625.GO30452@random.random>
 <20100126164230.GC16468@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126164230.GC16468@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> hugetlbfs may be not be ideal, but it's not quite as catastrophic as
> commonly believed either.

I want 100% of userbase to take advantage of it, hugetlbfs isn't even
mounted by default... and there is no way to use libhugetlbfs by
default.

I think hugetlbfs is fine for a niche of users (for those power users
kernel hackers and huge DBMS it may also be better than transparent
hugepage and they should keep using it!!! thanks to being able to
reserve pages at boot), but for the 99% of userbase it's exactly as
catastrophic as commonly believed. Otherwise I am 100% sure that I
wouldn't be the first one on linux to decrease the tlb misses with 2M
pages while watching videos on youtube (>60M on hugepages will happen
with atom netbook). And that's nothing compared to many other
workloads. Yes not so important for desktop but on server especially
with EPT/NPT it's a must and hugetlbfs is as catastrophic as on
"default desktop" in the virtualization cloud.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
