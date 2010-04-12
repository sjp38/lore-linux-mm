Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E0C326B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 09:18:21 -0400 (EDT)
Date: Mon, 12 Apr 2010 15:17:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412131711.GX5656@random.random>
References: <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <20100412070811.GD5656@random.random>
 <20100412072144.GS5683@laptop>
 <20100412080626.GG5656@random.random>
 <20100412104451.GO25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412104451.GO25756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 11:44:51AM +0100, Mel Gorman wrote:
> As a side-note, this is what dynamic hugepage pool resizing was for.
> 
> hugeadm --pool-pages-max <size|DEFAULT>:[+|-]<pagecount|memsize<G|M|K>>
> 
> The hugepage pool grows and shrinks as required if the system is able to
> allocate the huge pages. If the huge pages are not available, mmap() returns
> NULL and userspace is expected to recover by retrying the allocation with
> small pages (something libhugetlbfs does automatically).

If 99% of the virtual space is backed by hugepages and just the last
2M have to be backed by regular pages that's fine with us, we want to
use hugepages for the 99% of the memory.

> In the virtualisation context, the greater problem with such an approach
> is no-overcommit is possible. I am given to understand that this is a
> major problem because hosts of virtual machines are often overcommitted
> on the assumption they don't all peak at the same time.

Yep, other things that come to mind is that we need KSM to split and
merge hugepages when they're found equal, not yet working right now
but it's more natural to do it in the core VM as KSM pages then have
to be swapped too and mixed in the same vma with regular pages and
hugepages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
