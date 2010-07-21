Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A79C66B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 16:54:47 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5X0071NE38M090@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 21:54:44 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5X00L55E37IF@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jul 2010 21:54:44 +0100 (BST)
Date: Wed, 21 Jul 2010 22:56:08 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1279745143.31376.46.camel@c-dwalke-linux.qualcomm.com>
Message-id: <op.vf7ofuif7p4s8u@pikus>
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
 <op.vf7lipj67p4s8u@pikus>
 <1279742604.31376.40.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7mvhvn7p4s8u@pikus>
 <1279744472.31376.42.camel@c-dwalke-linux.qualcomm.com>
 <op.vf7nuzu57p4s8u@pikus>
 <1279745143.31376.46.camel@c-dwalke-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 22:45:43 +0200, Daniel Walker <dwalker@codeaurora.or=
g> wrote:
> Your not hearing the issues.. IT'S TOO COMPLEX! Please remove it.

Remove what exactly?

The command line parameter? It's like 50 lines of code, so I don't
see any benefits.

The possibility to specify the configuration? It would defy the whole
purpose of CMA, so I won't do that.

The complexity has to be there one way or the other and even though
I am aware that less complex code is the better and am trying to
remove unnecessary complexity but saying =E2=80=9Cremove it=E2=80=9D won=
't make any
good unless you provide me with a better alternative.  At this point,
I am still convinced that the string parameters are the best option.

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
