Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 78ECA6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 10:30:15 -0400 (EDT)
Received: from eu_spt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L5W00FLYWACM9@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 21 Jul 2010 15:30:12 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5W009B0WABIP@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 15:30:12 +0100 (BST)
Date: Wed, 21 Jul 2010 16:31:35 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100721135229.GC10930@sirena.org.uk>
Message-id: <op.vf66mxka7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus> <20100721135229.GC10930@sirena.org.uk>
Sender: owner-linux-mm@kvack.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Daniel Walker <dwalker@codeaurora.org>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 15:52:30 +0200, Mark Brown <broonie@opensource.wolfs=
onmicro.com> wrote:

> On Tue, Jul 20, 2010 at 09:14:58PM +0200, Micha?? Nazarewicz wrote:
>> On Tue, 20 Jul 2010 20:15:24 +0200, Daniel Walker <dwalker@codeaurora=
.org> wrote:
>
>> > If you have this disconnected from the drivers it will just cause
>> > confusion, since few will know what these parameters should be for =
a
>> > given driver set. It needs to be embedded in the kernel.
>
>> I see your point but the problem is that devices drivers don't know t=
he
>> rest of the system neither they know what kind of use cases the syste=
m
>> should support.
>
> If this does need to be configured per system would having platform da=
ta
> of some kind in the kernel not be a sensible a place to do it,

The current version (and the next version I'm working on) of the code
has cma_defaults() call.  It is intended to be called from platform
initialisation code to provide defaults.

> or even
> having a way of configuring this at runtime (after all, the set of
> currently active users may vary depending on the current configuration=

> and keeping everything allocated all the time may be wasteful)?

I am currently working on making the whole thing more dynamic.  I imagin=
e
the list of regions would stay pretty much the same after kernel has
started (that's because one cannot reliably allocate new big contiguous
memory regions) but it will be possible to change the set of rules, etc.=



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
