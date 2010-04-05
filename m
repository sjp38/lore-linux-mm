Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2624D6B01E3
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 16:46:30 -0400 (EDT)
Received: by fxm2 with SMTP id 2so1568250fxm.10
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 13:46:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
References: <patchbomb.1270168887@v2.random>
	 <20100405120906.0abe8e58.akpm@linux-foundation.org>
	 <20100405193616.GA5125@elte.hu>
	 <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
	 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
Date: Mon, 5 Apr 2010 23:46:27 +0300
Message-ID: <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Linus,

On Mon, Apr 5, 2010 at 11:32 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>> AFAIK, most modern GCs split memory in young and old generation
>> "zones" and _copy_ surviving objects from the former to the latter if
>> their lifetime exceeds some threshold. The JVM keeps scanning the
>> smaller young generation very aggressively which causes TLB pressure
>> and scans the larger old generation less often.
>
> .. my only input to this is: numbers talk, bullsh*t walks.
>
> I'm not interested in micro-benchmarks, either. I can show infinite TLB
> walk improvement in a microbenchmark.
>
> In order for me to be interested in any complex hugetlb crap, I want real
> numbers from real applications. Not "it takes this many cycles to walk a
> page table", or "it could matter under these circumstances".
>
> I also want those real numbers _not_ directly after a clean reboot, but
> after running other real loads on the machine that have actually used up
> all the memory and filled it with things like dentry data etc. The "right
> after boot" case is totally pointless, since a huge part of hugetlb
> entries is the ability to allocate those physically contiguous and
> well-aligned regions.
>
> Until then, it's just extra complexity for no actual gain.
>
> Oh, and while I'm at it, I want a pony too.

Unfortunately I wasn't able to find a pony on Google but here are some
huge page numbers if you're interested:

  http://zzzoot.blogspot.com/2009/02/java-mysql-increased-performance-with.html

I'm actually bit surprised you find the issue controversial, Linus. I
am not a real JVM hacker (although I could probably play one on TV)
but the "hugepages are a big win" argument seems pretty logical for
any GC heavy activity. Wouldn't be the first time I was wrong, though.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
