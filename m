Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D8D486B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 11:46:43 -0400 (EDT)
Date: Mon, 12 Apr 2010 08:41:01 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: hugepages will matter more in the future
In-Reply-To: <20100411194010.GC5656@random.random>
Message-ID: <alpine.LFD.2.00.1004120836440.26679@i5.linux-foundation.org>
References: <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com> <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu> <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org> <20100411194010.GC5656@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>



On Sun, 11 Apr 2010, Andrea Arcangeli wrote:

> On Sun, Apr 11, 2010 at 08:22:04AM -0700, Linus Torvalds wrote:
> >  - magic libc malloc flags tghat are totally and utterly unrealistic in 
> >    anything but a benchmark
> > 
> >  - by basically keeping one CPU totally busy doing defragmentation.
> 
> This is a red herring. This is the last thing we want, and we'll run
> even faster if we could make current glibc binaries to cooperate. But
> this is a new feature and it'll require changing glibc slightly.

So if it is a red herring, why the hell did you do your numbers with it?

Also, talking about "changing glibc slightly" is another sign of just 
denial of reality. You realize that a lot of apps (especially the ones 
with large VM footprints) do not use glibc malloc at all, exactly because 
it has some bad properties particularly with threading?

I saw people quote firefox mappings in this thread. You realize that 
firefox is one such application?

> Future glibc will be optimal and it won't require khugepaged don't
> worry.

Sure. "All problems are imaginary".

> I got crashes in page_mapcount != number of huge_pmd mapping the page
> in split_huge_page because of the anon-vma bug, so I had to back it
> out, this is why it's stable now.

Ok. My deeper point really was that all the VM people seem to be in this 
circlejerk to improve performance, and it looks like nobody is even trying 
to fix the _existing_ problem (caused by another try to improve 
performance).

I'm totally unimpressed with the whole circus partly exactly due to that.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
