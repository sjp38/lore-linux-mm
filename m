Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AEFBB6B01EF
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:43:35 -0400 (EDT)
Date: Mon, 5 Apr 2010 18:38:35 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <20100406011345.GT5825@random.random>
Message-ID: <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
References: <patchbomb.1270168887@v2.random> <20100405120906.0abe8e58.akpm@linux-foundation.org> <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>



On Tue, 6 Apr 2010, Andrea Arcangeli wrote:
>
> In short I first measured the page fault improvement in host (~+50%
> faster, sure that has nothing to do with pmd_huge or the tlb miss, I
> said I mentioned it just for curiosity in fact), then measured the tlb
> miss improvement in host (a few percent faster as usual with
> hugetlbfs) then measured the boost in guest if host uses hugepages
> (with no guest kernel change at all, just the tlb miss going faster in
> guest and that boosts the guest kernel compile 6%) and then some other
> test with dd with all combinations of host/guest using hugepages or
> not, and also with dd run on bare metal with or without hugepages.

Yeah, sorry. I misread your email - I noticed that 6% improvement for 
something that looked like a workload I might actually _care_ about, and 
didn't track the context enough to notice that it was just for the "host 
is using hugepages" case.

So I thought it was a more interesting load than it was. The 
virtualization "TLB miss is expensive" load I can't find it in myself to 
care about. "Get a better CPU" is my answer to that one,

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
