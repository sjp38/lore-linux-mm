Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAE746B01E3
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 16:38:04 -0400 (EDT)
Date: Mon, 5 Apr 2010 13:32:21 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
References: <patchbomb.1270168887@v2.random>  <20100405120906.0abe8e58.akpm@linux-foundation.org>  <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>



On Mon, 5 Apr 2010, Pekka Enberg wrote:
> 
> AFAIK, most modern GCs split memory in young and old generation
> "zones" and _copy_ surviving objects from the former to the latter if
> their lifetime exceeds some threshold. The JVM keeps scanning the
> smaller young generation very aggressively which causes TLB pressure
> and scans the larger old generation less often.

.. my only input to this is: numbers talk, bullsh*t walks. 

I'm not interested in micro-benchmarks, either. I can show infinite TLB 
walk improvement in a microbenchmark.

In order for me to be interested in any complex hugetlb crap, I want real 
numbers from real applications. Not "it takes this many cycles to walk a 
page table", or "it could matter under these circumstances".

I also want those real numbers _not_ directly after a clean reboot, but 
after running other real loads on the machine that have actually used up 
all the memory and filled it with things like dentry data etc. The "right 
after boot" case is totally pointless, since a huge part of hugetlb 
entries is the ability to allocate those physically contiguous and 
well-aligned regions.

Until then, it's just extra complexity for no actual gain.

Oh, and while I'm at it, I want a pony too.

			Linus

PS. I also think the current odd anonvma thing is _way_ more important. 
That was a feature that actually improved AIM throughput by 300%. Now, 
admittedly that's not a real load either, but at least it's not a total 
microbenchmark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
