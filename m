Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D69A56B0088
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 10:56:09 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LB2001KS45IZI@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 29 Oct 2010 15:56:07 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LB200CTT45I0E@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Oct 2010 15:56:06 +0100 (BST)
Date: Fri, 29 Oct 2010 16:58:31 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
In-reply-to: <20101029142741.GB19823@gargoyle.fritz.box>
Message-id: <op.vlcejtth7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
 <op.vlbywq137p4s8u@pikus> <20101029103154.GA10823@gargoyle.fritz.box>
 <20101029195900.88559162.kamezawa.hiroyu@jp.fujitsu.com>
 <20101029122928.GA17792@gargoyle.fritz.box> <op.vlb8bda87p4s8u@pikus>
 <20101029142741.GB19823@gargoyle.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi.kleen@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <pawel@osciak.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 16:27:41 +0200, Andi Kleen <andi.kleen@intel.com> wr=
ote:

> On Fri, Oct 29, 2010 at 01:43:51PM +0100, Micha=C5=82 Nazarewicz wrote=
:
>> Hmm... true.  Still the point remains that only movable and reclaimab=
le pages are
>> allowed in the marked regions.  This in effect means that from unmova=
ble pages
>> point of view, the area is unusable but I havn't thought of any other=
 way to
>> guarantee that because of fragmentation, long sequence of free/movabl=
e/reclaimable
>> pages is available.

> Essentially a movable zone as defined today.

Ah, right, I somehow was under the impresion that movable zone can be us=
ed as a fallback
zone.  When I'm finished with my current approach I'll look more closely=
 into it.

> That gets you near all the problems of highmem (except for the mapping=

> problem and you're a bit more flexible in the splits):
>
> Someone has to decide at boot how much should be movable
> and what not, some workloads will run out of space, some may
> deadlock when it runs out of management objects, etc.etc.
> Classic highmem had a long string of issues with all of this.

Here's where the rest of CMA comes.  The solution may be not perfect but=
 it's
probably better then nothing.  The idea is to define regions for each de=
vice
(with possibility for a single region to be shared) which, hopefuly, can=
 help
with fragmentation.

In the current form, CMA is designed mostly for embeded systems where on=
e can
define what kind of devices will be used, but in general this could be u=
sed
for other systems as well.

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
