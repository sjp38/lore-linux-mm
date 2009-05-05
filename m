Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 24EE46B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 17:09:40 -0400 (EDT)
Date: Tue, 5 May 2009 14:05:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/3] mm: introduce follow_pte()
Message-Id: <20090505140517.bef78dd3.akpm@linux-foundation.org>
In-Reply-To: <20090505203807.GB2428@cmpxchg.org>
References: <20090501181449.GA8912@cmpxchg.org>
	<1241430874-12667-1-git-send-email-hannes@cmpxchg.org>
	<20090505122442.6271c7da.akpm@linux-foundation.org>
	<20090505203807.GB2428@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: magnus.damm@gmail.com, linux-media@vger.kernel.org, hverkuil@xs4all.nl, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 May 2009 22:38:07 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, May 05, 2009 at 12:24:42PM -0700, Andrew Morton wrote:
> > On Mon,  4 May 2009 11:54:32 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > A generic readonly page table lookup helper to map an address space
> > > and an address from it to a pte.
> > 
> > umm, OK.
> > 
> > Is there actually some point to these three patches?  If so, what is it?
> 
> Magnus needs to check for physical contiguity of a VMAs backing pages
> to support zero-copy exportation of video data to userspace.
> 
> This series implements follow_pfn() so he can walk the VMA backing
> pages and ensure their PFNs are in linear order.
> 
> [ This patch can be collapsed with 2/3, I just thought it would be
>   easier to read the diffs when having them separate. ]
> 
> 1/3 and 2/3: factor out the page table walk from follow_phys() into
> follow_pte().
> 
> 3/3: implement follow_pfn() on top of follow_pte().

So we could bundle these patches with Magnus's patchset, or we could
consider these three patches as a cleanup or something.

Given that 3/3 introduces an unused function, I'm inclined to sit tight
and await Magnus's work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
