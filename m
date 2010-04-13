Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B53DE6B01EF
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 07:39:39 -0400 (EDT)
Date: Tue, 13 Apr 2010 13:38:25 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100413113825.GD19757@elte.hu>
References: <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
 <4BC0E556.30304@redhat.com>
 <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <20100412042230.5d974e5d@infradead.org>
 <20100412133019.GZ5656@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412133019.GZ5656@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Avi Kivity <avi@redhat.com>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Mon, Apr 12, 2010 at 04:22:30AM -0700, Arjan van de Ven wrote:
> >
> > Now hugepages have some interesting other advantages, namely they save 
> > pagetable memory..which for something like TPC-C on a fork based database 
> > can be a measureable win.
> 
> It doesn't save pagetable memory (as in `grep MemFree /proc/meminfo`). [...]

It does save in terms of CPU cache footprint. (which the argument was about) 
The RAM is wasted, but are always cache cold.

> [...] I think the saving in pagetables isn't really interesting... [...]

i think it's very much interesting for 'pure' hugetlb mappings, as a next-step 
thing. It amounts to 8 bytes wasted per 4K page [0.2% of RAM wasted] - much 
more with the kind of aliasing that DBs frequently do - for hugetlb workloads 
it is basically roughly equivalent to a +8 bytes increase in struct page size 
- few MM hackers would accept that.

So it will have to be fixed down the line.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
