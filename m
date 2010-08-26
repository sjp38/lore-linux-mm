Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2EA816B01F0
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 00:03:03 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L7Q00C1YR8ZF9@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 26 Aug 2010 05:02:59 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Q00KXNR8Z1V@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 05:02:59 +0100 (BST)
Date: Thu, 26 Aug 2010 06:01:56 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
Message-id: <op.vh01hi2m7p4s8u@localhost>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop>
 <20100825155814.25c783c7.akpm@linux-foundation.org>
 <20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
 <op.vh0wektv7p4s8u@localhost>
 <20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
 <20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Hans Verkuil <hverkuil@xs4all.nl>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 128MB...too big ? But it's depend on config.

On embedded systems it may be like half of the RAM.  Or a quarter.  So b=
igger
granularity could be desired on some platforms.

> IBM's ppc guys used 16MB section, and recently, a new interface to shr=
ink
> the number of /sys files are added, maybe usable.
>
> Something good with this approach will be you can create "cma" memory
> before installing driver.

That's how CMA works at the moment.  But if I understand you correctly, =
what
you are proposing would allow to reserve memory *at* *runtime* long afte=
r system
has booted.  This would be a nice feature as well though.

> But yes, complicated and need some works.

> Ah, I need to clarify what I want to say.
>
> With compaction, it's helpful, but you can't get contiguous memory lar=
ger
> than MAX_ORDER, I think. To get memory larger than MAX_ORDER on demand=
,
> memory hot-plug code has almost all necessary things.

I'll try to look at it then.

> BTW, just curious...the memory for cma need not to be saved at
> hibernation ? Or drivers has to write its own hibernation ops by drive=
r suspend
> udev or some ?

Hibernation was not considered as of yet but I think it's device driver'=
s
responsibility more then CMA's especially since it may make little sense=
 to save
some of the buffers -- ie. no need to keep a frame from camera since it'=
ll be
overwritten just after system wakes up from hibernation.  It may also be=
 better
to stop playback and resume it later on rather than trying to save decod=
er's
state.  Again though, I haven't thought about hibernation as of yet.

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
