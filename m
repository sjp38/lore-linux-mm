Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 68C7A6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 15:51:43 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5X00DW5B63YL80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 20:51:39 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5X00955B62IP@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 20:51:39 +0100 (BST)
Date: Wed, 21 Jul 2010 21:53:03 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1279741029.31376.33.camel@c-dwalke-linux.qualcomm.com>
Message-id: <op.vf7lipj67p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
 <op.vf5o28st7p4s8u@pikus>
 <1279654698.26765.31.camel@c-dwalke-linux.qualcomm.com>
 <op.vf6zo9vb7p4s8u@pikus>
 <1279733750.31376.14.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7gt3qy7p4s8u@pikus>
 <1279736348.31376.20.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7h1yc47p4s8u@pikus>
 <1279738688.31376.24.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7j13067p4s8u@pikus>
 <1279741029.31376.33.camel@c-dwalke-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 21:37:09 +0200, Daniel Walker <dwalker@codeaurora.or=
g> wrote:
> What makes you assume that the bootloader would have these strings?
> Do your devices have these strings? Maybe mine don't have them.

I don't assume.  I only state it as one of the possibilities.

> Assume the strings are gone and you can't find them, or have no idea
> what they should be. What do you do then?

Ask Google?

I have a better question for you though: assume the "mem" parameter is
lost and you have no idea what it should be?  There are many parameters
passed to kernel by bootloader and you could ask about all of them.

Passing cma configuration via command line is one of the possibilities
-- especially convenient during development -- but I would expect platfo=
rm
defaults in a final product so you may well not need to worry about it.

Bottom line: if you destroyed your device, you are screwed.

>>>> Imagine a developer who needs to recompile the kernel and reflash t=
he
>>>> device each time she wants to change the configuration...  Command =
line
>>>> arguments seems a better option for development.

>>> So make it a default off debug configuration option ..

>> I don't really see the point of doing that.  Adding the command line
>> parameters is really a minor cost so there will be no benefits from
>> removing it.

> Well, I like my kernel minus bloat so that's a good reason. I don't se=
e
> a good reason to keep the interface in a production situation .. Maybe=

> during development , but really I don't see even a developer needing t=
o
> make the kind of changes your suggesting very often.

As I've said, removing the command line parameters would not benefit the=

kernel that much.  It's like 1% of the code or less.  On the other hand,=

it would add complexity to the CMA framework which is a good reason not
to do that.

Would you also argue about removing all the other kernel parameters as
well? I bet you don't use most of them.  Still they are there because
removing them would add too much complexity to the code (conditional
compilation, etc.).

I'm not saying that removing =E2=80=9Cbloat=E2=80=9D (or unused options =
if you will)
 from the kernel is a bad thing but there is a line where costs of
doing so negate the benefits.

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
