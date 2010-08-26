Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9A91F6B02BB
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 21:29:18 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L7Q007TZK4OGI@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 26 Aug 2010 02:29:17 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Q000EQK4MOO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 02:29:11 +0100 (BST)
Date: Thu, 26 Aug 2010 03:28:41 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
In-reply-to: <1282310110.2605.976.camel@laptop>
Message-id: <op.vh0ud3rg7p4s8u@localhost>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <p.osciak@samsung.com>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 15:15:10 +0200, Peter Zijlstra <peterz@infradead.org=
> wrote:
> So the idea is to grab a large chunk of memory at boot time and then
> later allow some device to use it?
>
> I'd much rather we'd improve the regular page allocator to be smarter
> about this. We recently added a lot of smarts to it like memory
> compaction, which allows large gobs of contiguous memory to be freed f=
or
> things like huge pages.
>
> If you want guarantees you can free stuff, why not add constraints to
> the page allocation type and only allow MIGRATE_MOVABLE pages inside a=

> certain region, those pages are easily freed/moved aside to satisfy
> large contiguous allocations.

I'm aware that grabbing a large chunk at boot time is a bit of waste of
space and because of it I'm hoping to came up with a way of reusing the
space when it's not used by CMA-aware devices.  My current idea was to
use it for easily discardable data (page cache?).

> Also, please remove --chain-reply-to from your git config. You're usin=
g
> 1.7 which should do the right thing (--no-chain-reply-to) by default.

OK.

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
