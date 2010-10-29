Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4952A6B0124
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 07:04:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9TB4bYr031888
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 20:04:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 933C345DE51
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:04:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 73AC345DE4F
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:04:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6117E1DB803C
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:04:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DFCD1DB8038
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:04:34 +0900 (JST)
Date: Fri, 29 Oct 2010 19:59:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
Message-Id: <20101029195900.88559162.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101029103154.GA10823@gargoyle.fritz.box>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
	<op.vlbywq137p4s8u@pikus>
	<20101029103154.GA10823@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi.kleen@intel.com>
Cc: =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <m.nazarewicz@samsung.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <pawel@osciak.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 12:31:54 +0200
Andi Kleen <andi.kleen@intel.com> wrote:

> > When I was posting CMA, it had been suggested to create a new migration type
> > dedicated to contiguous allocations.  I think I already did that and thanks to
> > this new migration type we have (i) an area of memory that only accepts movable
> > and reclaimable pages and 
> 
> Aka highmem next generation :-(
> 

yes. But Nick's new shrink_slab() may be a new help even without
new zone.


> > (ii) is used only if all other (non-reserved) pages have
> > been allocated.
> 
> That will be near always the case after some uptime, as memory fills up
> with caches. Unless you do early reclaim? 
> 

memory migration always do work with alloc_page() for getting migration target
pages. So, memory will be reclaimed if filled by cache.

About my patch, I may have to prealloc all required pages before start.
But I didn't do that at this time.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
