Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 28C896B02A9
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 21:09:18 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7F00GX4F7C9S70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 02:09:14 +0100 (BST)
Received: from localhost ([10.89.8.241])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7F00MC3F62AL@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 02:09:12 +0100 (BST)
Date: Fri, 20 Aug 2010 03:08:24 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv3 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100820001339N.fujita.tomonori@lab.ntt.co.jp>
Message-id: <op.vhppgaxq7p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1281100495.git.m.nazarewicz@samsung.com>
 <AANLkTikp49oOny-vrtRTsJvA3Sps08=w7__JjdA3FE8t@mail.gmail.com>
 <20100820001339N.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: kyungmin.park@samsung.com, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-mm@kvack.org, dwalker@codeaurora.org, linux@arm.linux.org.uk, corbet@lwn.net, p.osciak@samsung.com, broonie@opensource.wolfsonmicro.com, linux-kernel@vger.kernel.org, hvaibhav@ti.com, hverkuil@xs4all.nl, kgene.kim@samsung.com, zpfeffer@codeaurora.org, jaeryul.oh@samsung.com, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010 17:15:12 +0200, FUJITA Tomonori <fujita.tomonori@lab=
.ntt.co.jp> wrote:

> On Wed, 18 Aug 2010 12:01:35 +0900
> Kyungmin Park <kyungmin.park@samsung.com> wrote:
>
>> Are there any comments or ack?
>>
>> We hope this method included at mainline kernel if possible.
>> It's really needed feature for our multimedia frameworks.
>
> You got any comments from mm people?
>
> Virtually, this adds a new memory allocator implementation that steals=

> some memory from memory allocator during boot process. Its API looks
> completely different from the API for memory allocator. That doesn't
> sound appealing to me much. This stuff couldn't be integrated well
> into memory allocator?

What kind of integration do you mean?  I see three levels:

1. Integration on API level meaning that some kind of existing API is us=
ed
    instead of new cma_*() calls.  CMA adds notion of devices and memory=

    types which is new to all the other APIs (coherent has notion of dev=
ices
    but that's not enough).  This basically means that no existing API c=
an be
    used for CMA.  On the other hand, removing notion of devices and mem=
ory
    types would defeat the whole purpose of CMA thus destroying the solu=
tion
    that CMA provides.

2. Reuse of memory pools meaning that memory reserved by CMA can then be=

    used by other allocation mechanisms.  This is of course possible.  F=
or
    instance coherent could easily be implemented as a wrapper to CMA.
    This is doable and can be done in the future after CMA gets more
    recognition.

3. Reuse of algorithms meaning that allocation algorithms used by other
    allocators will be used with CMA regions.  This is doable as well an=
d
    can be done in the future.

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
