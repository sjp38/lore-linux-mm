Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D2386B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 15:18:42 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5X007G39PHUA80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 20:20:05 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5X00FMF9PHLH@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 20:20:05 +0100 (BST)
Date: Wed, 21 Jul 2010 21:21:29 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1279738688.31376.24.camel@c-dwalke-linux.qualcomm.com>
Message-id: <op.vf7j13067p4s8u@pikus>
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
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 20:58:08 +0200, Daniel Walker <dwalker@codeaurora.or=
g> wrote:

> On Wed, 2010-07-21 at 20:38 +0200, Micha=C5=82 Nazarewicz wrote:
>> > On Wed, 2010-07-21 at 20:11 +0200, Micha=C5=82 Nazarewicz wrote:
>> >> Not really.  This will probably be used mostly on embedded systems=

>> >> where users don't have much to say as far as hardware included on =
the
>> >> platform is concerned, etc.  Once a phone, tablet, etc. is release=
d
>> >> users will have little need for customising those strings.
>>
>> On Wed, 21 Jul 2010 20:19:08 +0200, Daniel Walker <dwalker@codeaurora=
.org> wrote:
>> > You can't assume that user won't want to reflash their own kernel o=
n the
>> > device. Your assuming way too much.
>>
>> If user is clever enough to reflash a phone she will find the strings=

>> easy especially that they are provided from: (i) bootloader which is
>> even less likely to be reflashed and if someone do reflash bootloader=

>> she is a guru who'd know how to make the strings; or (ii) platform
>> defaults which will be available with the rest of the source code
>> for the platform.
>
> Your, again, assuming all sorts of stuff .. On my phone for example it=

> is very easy to reflash, personally, I think most devices will be like=

> that in the future. so you don't _need_ to be clever to reflash the
> device.

Bottom line is: if you reflash the device you (i) get an image from
somewhere and it has the strings in it, (ii) reflash the kernel and
parameters are provided by bootloader so they still remain, (iii)
use platform default strings which you get with the source codes and
include when kernel is built, or (iv) are a guru who knows what to
do.

>> > If you assume they do want their own kernel then they would need th=
is
>> > string from someplace. If your right and this wouldn't need to chan=
ge,
>> > why bother allowing it to be configured at all ?
>>
>> Imagine a developer who needs to recompile the kernel and reflash the=

>> device each time she wants to change the configuration...  Command li=
ne
>> arguments seems a better option for development.
>
> So make it a default off debug configuration option ..

I don't really see the point of doing that.  Adding the command line
parameters is really a minor cost so there will be no benefits from
removing it.

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
