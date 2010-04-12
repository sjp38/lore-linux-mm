Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 561116B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 10:32:44 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:29:03 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <r2j84144f021004112318v78f28c3ds46531d1233966a20@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004120928020.12455@router.home>
References: <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>  <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu>  <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu>  <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu>
  <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu>  <20100412060931.GP5683@laptop> <r2j84144f021004112318v78f28c3ds46531d1233966a20@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Apr 2010, Pekka Enberg wrote:

> > Especially when you use something like SLUB as the memory allocator
> > which requires higher order allocations for objects which are pinned
> > in kernel memory.
>
> I guess we'd need to merge the SLUB defragmentation patches to fix that?

1. SLUB does not require higher order allocations.

2. SLUB defrag patches would allow reclaim / moving of slab memory but
would require callbacks to be provided by slab users to remove references
to objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
