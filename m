Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B33A66B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:35:33 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5X00DG97PCNC80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 19:36:48 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5X009W37PBIP@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 19:36:48 +0100 (BST)
Date: Wed, 21 Jul 2010 20:38:12 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1279736348.31376.20.camel@c-dwalke-linux.qualcomm.com>
Message-id: <op.vf7h1yc47p4s8u@pikus>
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
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wed, 2010-07-21 at 20:11 +0200, Micha=C5=82 Nazarewicz wrote:
>> Not really.  This will probably be used mostly on embedded systems
>> where users don't have much to say as far as hardware included on the=

>> platform is concerned, etc.  Once a phone, tablet, etc. is released
>> users will have little need for customising those strings.

On Wed, 21 Jul 2010 20:19:08 +0200, Daniel Walker <dwalker@codeaurora.or=
g> wrote:
> You can't assume that user won't want to reflash their own kernel on t=
he
> device. Your assuming way too much.

If user is clever enough to reflash a phone she will find the strings
easy especially that they are provided from: (i) bootloader which is
even less likely to be reflashed and if someone do reflash bootloader
she is a guru who'd know how to make the strings; or (ii) platform
defaults which will be available with the rest of the source code
for the platform.

> If you assume they do want their own kernel then they would need this
> string from someplace. If your right and this wouldn't need to change,=

> why bother allowing it to be configured at all ?

Imagine a developer who needs to recompile the kernel and reflash the
device each time she wants to change the configuration...  Command line
arguments seems a better option for development.

And the configuration is needed because it is platform-dependent
so it needs to be set for each platform.

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
