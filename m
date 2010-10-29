Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 13D116B00EA
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 06:29:43 -0400 (EDT)
Date: Fri, 29 Oct 2010 12:31:54 +0200
From: Andi Kleen <andi.kleen@intel.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
Message-ID: <20101029103154.GA10823@gargoyle.fritz.box>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
 <op.vlbywq137p4s8u@pikus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.vlbywq137p4s8u@pikus>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <pawel@osciak.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

> When I was posting CMA, it had been suggested to create a new migration type
> dedicated to contiguous allocations.  I think I already did that and thanks to
> this new migration type we have (i) an area of memory that only accepts movable
> and reclaimable pages and 

Aka highmem next generation :-(

> (ii) is used only if all other (non-reserved) pages have
> been allocated.

That will be near always the case after some uptime, as memory fills up
with caches. Unless you do early reclaim? 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
