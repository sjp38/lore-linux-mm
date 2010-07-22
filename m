Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80B7D6B02A4
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 07:48:02 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5Y00JWBJG1ZJ60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 12:48:01 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5Y0050VJG0EK@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 12:48:01 +0100 (BST)
Date: Thu, 22 Jul 2010 13:49:26 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100722191658V.fujita.tomonori@lab.ntt.co.jp>
Message-id: <op.vf8tsock7p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: <000001cb296f$6eba8fa0$4c2faee0$%szyprowski@samsung.com>
 <20100722183432U.fujita.tomonori@lab.ntt.co.jp> <op.vf8oa80k7p4s8u@pikus>
 <20100722191658V.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: m.szyprowski@samsung.com, corbet@lwn.net, linux-mm@kvack.org, p.osciak@samsung.com, xiaolin.zhang@intel.com, hvaibhav@ti.com, robert.fekete@stericsson.com, marcus.xm.lorentzon@stericsson.com, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com
List-ID: <linux-mm.kvack.org>

> On Thu, 22 Jul 2010 11:50:58 +0200
> **UNKNOWN CHARSET** <m.nazarewicz@samsung.com> wrote:
>> So you are talking about moving complexity from the CMA core to the d=
rivers.

On Thu, 22 Jul 2010 12:17:42 +0200, FUJITA Tomonori <fujita.tomonori@lab=
.ntt.co.jp> wrote:
> I don't think that adjusting some drivers about how they use memory is=

> so complicated. Just about how much and exclusive or share.

I don't believe it is that simple.  If shared then with what?  What if
foo-dev can share with bar-dev and baz-dev can share with qux-dev?

Also, even if its 10 lines of code in each driver isn't it worth
removing from the driver and not let it worry about it?

The configuration needs to be specified one way of another, my approach
with CMA was to centralise it so that drivers do not need to worry about=

it.

> And adjusting drivers in embedded systems is necessary anyway.

It should not be...

> It's too complicated feature that isn't useful for the majority.

Please consider what I've written in discussion with Mark Brown.

>> Lost you there...  If something does not make sense on your system yo=
u
>> don't configure CMA to do that. That's one of the points of CMA.  Wha=
t
>> does not make sense on your platform may make perfect sense on some
>> other system, with some other drivers maybe.

> What's your point? The majority of features (e.g. scsi, ata, whatever)=

> works in that way. They are useful on some and not on some.

My point is, that you can configure CMA the way you want...

> Are you saying, "my system needs this feature. You can disable it if
> you don't need it. so let's merge it. it doesn't break your system."?

No.  I'm saying many of the embedded systems without IO MMU need to be
able to allocate contiguous memory chunks.  I'm also saying there is at
least one system where some non-trivial configuration is needed and
adding configuration handling to CMA is not as big of a cost as one may
imagine.

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
