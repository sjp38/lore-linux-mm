Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3BCBA6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 04:19:10 -0400 (EDT)
Date: Mon, 12 Apr 2010 10:18:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412081813.GH5656@random.random>
References: <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <20100412070811.GD5656@random.random>
 <20100412072144.GS5683@laptop>
 <4BC2D0C9.3060201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2D0C9.3060201@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 10:50:33AM +0300, Avi Kivity wrote:
> The problem with hugetlbfs is that you need to commit upfront to using 
> it, and that you need to be the admin.  For virtualization, you want to 
> use hugepages when there is no memory pressure, but you want to use ksm, 
> ballooning, and swapping when there is (and then go back to large pages 
> when pressure is relieved, e.g. by live migration).
> 
> HPC and databases can probably live with hugetlbfs.  JVM is somewhere in 
> the middle, they do allocate memory dynamically.

I guess lots of the recent work on hugetlbfs has been exactly meant to
try to make hugetlbfs more palatable by things like JVM, the end
result is that it's growing in its own parallel VM but very still
crippled down compared to the real kernel VM.

I see very long term value in hugetlbfs, for example for CPUs that
can't mix different page sizes in the same VMA, or for the 1G page
reservation (no way we're going to slowdown everything increasing
MAX_ORDER so much by default even if fragmentation issues wouldn't
grow exponentially with the order) but I think hugetlbfs should remain
simple and cover optimally these use cases, without trying to expand
itself into the dynamic area of transparent usages where it wasn't
designed to be used in the first place and where it's not a too good
fit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
