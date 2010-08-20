Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AB5D96B0324
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 06:54:47 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L7G00C2O6BAW1@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 20 Aug 2010 11:54:46 +0100 (BST)
Received: from localhost ([10.89.8.241])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7G000CR6A43V@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 11:54:45 +0100 (BST)
Date: Fri, 20 Aug 2010 12:54:02 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv3 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100820193328P.fujita.tomonori@lab.ntt.co.jp>
Message-id: <op.vhqgkcgj7p4s8u@localhost>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <op.vhp4pws27p4s8u@localhost>
 <20100820155617S.fujita.tomonori@lab.ntt.co.jp> <op.vhp7rxz77p4s8u@localhost>
 <20100820193328P.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: hverkuil@xs4all.nl, dwalker@codeaurora.org, linux@arm.linux.org.uk, corbet@lwn.net, p.osciak@samsung.com, broonie@opensource.wolfsonmicro.com, linux-kernel@vger.kernel.org, hvaibhav@ti.com, linux-mm@kvack.org, kyungmin.park@samsung.com, kgene.kim@samsung.com, zpfeffer@codeaurora.org, jaeryul.oh@samsung.com, m.szyprowski@samsung.com, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 12:35:01 +0200, FUJITA Tomonori <fujita.tomonori@lab=
.ntt.co.jp> wrote:

> On Fri, 20 Aug 2010 10:10:45 +0200
> **UNKNOWN CHARSET** <m.nazarewicz@samsung.com> wrote:
>
>> > I wrote "similar to the existing API', not "reuse the existing API"=
.
>>
>> Yes, but I don't really know what you have in mind.  CMA is similar t=
o various
>> APIs in various ways: it's similar to any allocator since it takes
>> size in bytes,
>
> why don't take gfp_t flags?

Because they are insufficient.  Either that or I don't understand gfp_t.=


With CMA, platform can define many memory types.  For instance, if there=
 are
two memory bans there can be two memory types for the two banks.  For at=
 least one
of the device I'm in contact with, another type for it's firmware is als=
o needed.
Bottom line is that there may be possibly many types which won't map to =
gfp_t.

> Something like dev_alloc_page is more appropriate name?

Two things: I'd prefer a "cma" prefix rather then "dev" and I think it s=
hould
be "pages", right? Then, size should be given in pages rather then bytes=
.

Nonetheless, I don't really see at the moment why this should be better.=


> Or something similar to dmapool API (mm/dmapool.c) might work
> better. The purpose of dmapool API is creating a pool for consistent
> memory per device. It's similar to yours, creating a pool for
> contiguous memory per device(s)?

I'll try to look at it later on and think about it.  I'm still somehow r=
eluctant
to change the names but still, thank you for suggestions.

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
