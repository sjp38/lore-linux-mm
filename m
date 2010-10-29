Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 89FFE6B00E8
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 10:26:00 -0400 (EDT)
Date: Fri, 29 Oct 2010 16:27:41 +0200
From: Andi Kleen <andi.kleen@intel.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
Message-ID: <20101029142741.GB19823@gargoyle.fritz.box>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
 <op.vlbywq137p4s8u@pikus>
 <20101029103154.GA10823@gargoyle.fritz.box>
 <20101029195900.88559162.kamezawa.hiroyu@jp.fujitsu.com>
 <20101029122928.GA17792@gargoyle.fritz.box>
 <op.vlb8bda87p4s8u@pikus>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.vlb8bda87p4s8u@pikus>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <pawel@osciak.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2010 at 01:43:51PM +0100, MichaA? Nazarewicz wrote:
> >>>> (ii) is used only if all other (non-reserved) pages have
> >>>> been allocated.
> 
> >>> That will be near always the case after some uptime, as memory fills up
> >>> with caches. Unless you do early reclaim?
> 
> Hmm... true.  Still the point remains that only movable and reclaimable pages are
> allowed in the marked regions.  This in effect means that from unmovable pages
> point of view, the area is unusable but I havn't thought of any other way to
> guarantee that because of fragmentation, long sequence of free/movable/reclaimable
> pages is available.

Essentially a movable zone as defined today.

That gets you near all the problems of highmem (except for the mapping
problem and you're a bit more flexible in the splits): 

Someone has to decide at boot how much should be movable
and what not, some workloads will run out of space, some may
deadlock when it runs out of management objects, etc.etc. 
Classic highmem had a long string of issues with all of this.

If it was an easy problem it had been long solved, but it isn't really.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
