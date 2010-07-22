Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2EAB86B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:33:30 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L5Y001F8D7P44@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 22 Jul 2010 10:33:27 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5Y00E3PD7PUO@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 10:33:25 +0100 (BST)
Date: Thu, 22 Jul 2010 11:34:50 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1279746102.31376.47.camel@c-dwalke-linux.qualcomm.com>
Message-id: <op.vf8nkct57p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
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
 <op.vf7lipj67p4s8u@pikus>
 <1279742604.31376.40.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7mvhvn7p4s8u@pikus>
 <1279744472.31376.42.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7nuzu57p4s8u@pikus>
 <1279745143.31376.46.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7ofuif7p4s8u@pikus>
 <1279746102.31376.47.camel@c-dwalke-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 23:01:42 +0200, Daniel Walker <dwalker@codeaurora.or=
g> wrote:

> On Wed, 2010-07-21 at 22:56 +0200, Micha=C5=82 Nazarewicz wrote:
>> On Wed, 21 Jul 2010 22:45:43 +0200, Daniel Walker <dwalker@codeaurora=
.org> wrote:
>> > Your not hearing the issues.. IT'S TOO COMPLEX! Please remove it.
>>
>> Remove what exactly?
>
> Remove the command line option and all related code, or make it all a
> debug option.

How convenient... you have stripped the part of my mail where I describe=
d
why this is request have no sense.  I'll quote myself then:

>> The command line parameter? It's like 50 lines of code, so I don't
>> see any benefits.

As such, I'm not going to add bunch of #ifdefs just to remove 50 lines
of code.

>> The possibility to specify the configuration? It would defy the whole=

>> purpose of CMA, so I won't do that.

Simply as that.  We work with a platform where whole of the functionalit=
y
provided by CMA is required (many regions, region start address, region
alignment, device->region mapping).

This means, what I keep repeating and you keep ignoring, that the comple=
xity
will be there if not as a parsing code then moved to the platform
initialisation code and drivers code.

One of the purposes of CMA is to hide the complexity inside CMA framewor=
k so
device driver authors and platform maintainers can use a simpler interfa=
ce.


Some time age (like year or two) I've posted some other solution to the
problem which served our purpose just well and had very little complexit=
y
in it.  Unfortunately, customising that solution was quite hard (require=
d
changes to a header file and adding modifying code for reserving space).=


Also, in this old solution, adding or removing regions required device
drivers to be modified.

This was not nice, not nice at all.  True, however, the core wasn't comp=
lex.


So when you say remove the complicity I say: I have been there, it's ugl=
y.


> Arguing with me isn't going to help your cause.

It's you who keep repeating =E2=80=9Cremove it, it's to complex=E2=80=9D=
 without
hearing my arguments.  I keep trying to show that all of the
functionality is required and is being used on our development
platform.

If your hardware does not require that complexity... well, you're one
lucky man.  Unfortunately, we are not, and we need a complex solution
to work with complex hardware.

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
