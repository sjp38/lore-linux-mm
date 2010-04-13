Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9BF896B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:05:21 -0400 (EDT)
Date: Tue, 13 Apr 2010 16:03:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100413140330.GR5583@random.random>
References: <20100412082844.GU5683@laptop>
 <4BC2E1D6.9040702@redhat.com>
 <20100412092615.GY5683@laptop>
 <4BC2EFBA.5080404@redhat.com>
 <20100412203829.871f1dee.akpm@linux-foundation.org>
 <20100413161802.498336ca@notabene.brown>
 <20100413133153.GO5583@random.random>
 <20100413134035.GY25756@csn.ul.ie>
 <20100413134456.GQ5583@random.random>
 <20100413135543.GA25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413135543.GA25756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael  S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 02:55:43PM +0100, Mel Gorman wrote:
> That already happens.

Yep as shown by /proc/pagetypeinfo.

> True. Christoph made a few stabs at being able to slab targetted reclaim
> (called defragmentation, but it was about reclaim) but it was never completed
> and merged. Even if it was merged, the slab reclaimable objects would
> still be kept in their own 2M pageblocks though.

I guess it's not easy and more expensive to reclaim in use object, I
didn't see the targetted reclaim patches. So it sounds ok if they stay
in their own pageblocks separated from the movable pageblocks, even if
they become fully reclaimable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
