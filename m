Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8C87B6B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 09:26:03 -0400 (EDT)
Date: Mon, 12 Apr 2010 15:25:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412132502.GY5656@random.random>
References: <20100412060931.GP5683@laptop>
 <4BC2BF67.80903@redhat.com>
 <20100412071525.GR5683@laptop>
 <4BC2CF8C.5090108@redhat.com>
 <20100412082844.GU5683@laptop>
 <4BC2E1D6.9040702@redhat.com>
 <20100412092615.GY5683@laptop>
 <4BC2EFBA.5080404@redhat.com>
 <20100412103701.GZ5683@laptop>
 <4BC2FCFA.5080004@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2FCFA.5080004@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 01:59:06PM +0300, Avi Kivity wrote:
> Right; and on a 16-64GB machine you'll have a hard time filling kernel 
> memory with objects.

Yep, this is worth mentioning, the more RAM there is, the higher
percentage of the freeable memory won't be fragmented, even without
kernelcore=. Which is probably why we won't ever need to worry about
kernelcore=.

> kvm overcommit uses ballooning, page merging, and swapping.  None of 
> these work well with large pages (well, ballooning might).

KSM is the only one that will need some further modification to be
able to merge the equal contents inside hugepages. It already can
co-exist (I tested it) but right now it will skip over hugepages and
it's only able to merge regular pages if there's any. We need to make
it hugepage aware and to split the hugepages when it finds stuff to
merge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
