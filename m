Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AD36B6B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 10:57:20 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5Y007B4S7IPV90@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 15:57:18 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5Y000E5S7IS0@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 15:57:18 +0100 (BST)
Date: Thu, 22 Jul 2010 16:58:43 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100722134056.GJ4737@rakim.wolfsonmicro.main>
Message-id: <op.vf82j5m17p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: <20100721135229.GC10930@sirena.org.uk> <op.vf66mxka7p4s8u@pikus>
 <20100721182457.GE10930@sirena.org.uk> <op.vf7h6ysh7p4s8u@pikus>
 <20100722090602.GF10930@sirena.org.uk>
 <000901cb297f$e28f2b10$a7ad8130$%szyprowski@samsung.com>
 <20100722105203.GD4737@rakim.wolfsonmicro.main> <op.vf8sxqro7p4s8u@pikus>
 <20100722124559.GH4737@rakim.wolfsonmicro.main> <op.vf8x60wi7p4s8u@pikus>
 <20100722134056.GJ4737@rakim.wolfsonmicro.main>
Sender: owner-linux-mm@kvack.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, Pawel Osciak <p.osciak@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010 15:40:56 +0200, Mark Brown <broonie@opensource.wolfs=
onmicro.com> wrote:

> On Thu, Jul 22, 2010 at 03:24:26PM +0200, Micha=C5=82 Nazarewicz wrote=
:
>
>> That's why command line is only intended as a way to overwrite the
>> defaults which are provided by the platform.  In a final product,
>> configuration should be specified in platform code and not on
>> command line.
>
> Yeah, agreed though I'm not convinced we can't do it via userspace
> (initrd would give us a chance to do stuff early) or just kernel
> rebuilds.

If there's any other easy way of overwriting platform's default I'm happ=
y
to listen. :)

>> >It sounds like apart from the way you're passing the configuration i=
n
>> >you're doing roughly what I'd suggest.  I'd expect that in a lot of
>> >cases the map could be satisfied from the default region so there'd =
be
>> >no need to explicitly set one up.
>
>> Platform can specify something like:
>
>> 	cma_defaults("reg=3D20M", "*/*=3Dreg");
>
>> which would make all the drivers share 20 MiB region by default.
>
> Yes, exactly - probably you can even have a default region backed by
> normal vmalloc() RAM which would at least be able to take a stab at
> working by default.

Not sure what you mean here.  vmalloc() allocated buffers cannot be used=

with CMA since they are not contiguous in memory.

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
