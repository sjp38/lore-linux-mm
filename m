Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DE0906B02CD
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 22:13:09 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7Q00AGHM5TG810@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 03:13:05 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Q00GP9M5SCH@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 03:13:04 +0100 (BST)
Date: Thu, 26 Aug 2010 04:12:10 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
Message-id: <op.vh0wektv7p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop>
 <20100825155814.25c783c7.akpm@linux-foundation.org>
 <20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010 02:58:57 +0200, KAMEZAWA Hiroyuki <kamezawa.hiroyu@j=
p.fujitsu.com> wrote:
> Hmm, you may not like this..but how about following kind of interface =
?
>
> Now, memoyr hotplug supports following operation to free and _isolate_=

> memory region.
> 	# echo offline > /sys/devices/system/memory/memoryX/state
>
> Then, a region of memory will be isolated. (This succeeds if there are=
 free
> memory.)
>
> Add a new interface.
>
> 	% echo offline > /sys/devices/system/memory/memoryX/state
> 	# extract memory from System RAM and make them invisible from buddy a=
llocator.
>
> 	% echo cma > /sys/devices/system/memory/memoryX/state
> 	# move invisible memory to cma.

At this point I need to say that I have no experience with hotplug memor=
y but
I think that for this to make sense the regions of memory would have to =
be
smaller.  Unless I'm misunderstanding something, the above would convert=

a region of sizes in order of GiBs to use for CMA.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
