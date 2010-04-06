Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8965D6B01F6
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 14:01:58 -0400 (EDT)
Date: Tue, 6 Apr 2010 13:00:43 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <4BBB6FEC.9050205@redhat.com>
Message-ID: <alpine.DEB.2.00.1004061259120.19151@router.home>
References: <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <4BBB052D.8040307@redhat.com> <4BBB2134.9090301@redhat.com> <20100406131024.GA5288@laptop> <4BBB359D.1020603@redhat.com> <20100406134539.GC5288@laptop> <20100406165031.GA5825@random.random> <4BBB6FEC.9050205@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 2010, Avi Kivity wrote:

> On 04/06/2010 07:50 PM, Andrea Arcangeli wrote:
> > On Tue, Apr 06, 2010 at 11:45:39PM +1000, Nick Piggin wrote:
> >
> > > problems. Speedups like Linus is talking about would refer to ways to
> > > speed up actual workloads, not ways to avoid fundamental limitations.
> > >
> > > Prefetching, memory parallelism, caches. It's worked for 25 years :)
> > >
> > This will always give you a worst case additional 6% on top (gcc is a
> > definitive worst case) of all other speedup of the actual workloads,
> > for server loads more likely>=15% boost. It's plain underclocking
> > your CPU not to run this.
> >
>
> I don't think gcc is worst case.  Workloads that benefit from large pages are
> those with bloated working sets that do a lot of pointer chasing and do little
> computation in between.  gcc fits two out of three (just a partial score on
> the first).

Once you have huge pages you will likely start to optimize for locality.

Pointer chasing is bad even with huge pages if you go between multiple
huge pages and you are beyond the number of huge tlb entries supported by
the cpu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
