Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E626D6B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 16:12:05 -0400 (EDT)
Date: Sat, 10 Apr 2010 22:10:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100410201057.GP5708@random.random>
References: <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <20100410200037.GO5708@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100410200037.GO5708@random.random>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 10:00:37PM +0200, Andrea Arcangeli wrote:
> and we need it to use non temporal stores, but even that will be

To clarify, I mean using temporal stores only on the CPUs with <8M L2
caches, with some of the Xeon preloading the cache may provide an even
further boost to the child with hugepages in addition to the further
longstanding benefits of hugetlb for long lived
allocations.

Furthermore there is also an option (only available when DEBUG_VM is
on, called transparent_hugepage/debug_cow) to COW with 4k copies
(exactly like we have to do if cow fails to allocate an hugepage, it's
the cow fallback) that already eliminates any chance for slowdown in
practice, but I don't recommend it at all, because it may provide a
minor speedup immediately after the cow with l2 cache <4M, but then it
slowdown the child forever and eliminates the more important
longstanding benefits.

And this in general is very nitpick at this point, but I just wanted
to cover all the details I'm aware about of the subtopic you mentioned
for completeness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
