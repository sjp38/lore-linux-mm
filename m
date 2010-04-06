Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C43CF6B01EF
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 13:27:21 -0400 (EDT)
Date: Tue, 6 Apr 2010 18:50:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406165031.GA5825@random.random>
References: <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <4BBB052D.8040307@redhat.com>
 <4BBB2134.9090301@redhat.com>
 <20100406131024.GA5288@laptop>
 <4BBB359D.1020603@redhat.com>
 <20100406134539.GC5288@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406134539.GC5288@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 11:45:39PM +1000, Nick Piggin wrote:
> problems. Speedups like Linus is talking about would refer to ways to
> speed up actual workloads, not ways to avoid fundamental limitations.
> 
> Prefetching, memory parallelism, caches. It's worked for 25 years :)

This will always give you a worst case additional 6% on top (gcc is a
definitive worst case) of all other speedup of the actual workloads,
for server loads more likely >=15% boost. It's plain underclocking
your CPU not to run this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
