Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CEC0F6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 22:42:11 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7S00FFDI690970@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2010 03:42:09 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7S00IV6I68TL@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2010 03:42:09 +0100 (BST)
Date: Fri, 27 Aug 2010 04:41:36 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
In-reply-to: <1282810627.1975.237.camel@laptop>
Message-id: <op.vh2sfmqt7p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop> <op.vh0ud3rg7p4s8u@localhost>
 <1282810627.1975.237.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <p.osciak@samsung.com>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010 10:17:07 +0200, Peter Zijlstra <peterz@infradead.org=
> wrote:
> So why not work on the page allocator to improve its contiguous
> allocation behaviour. If you look at the thing you'll find pageblocks
> and migration types. If you change it so that you pin the migration ty=
pe
> of one or a number of contiguous pageblocks to say MIGRATE_MOVABLE, so=

> that they cannot be used for anything but movable pages you're pretty
> much there.

And that's exactly where I'm headed.  I've created API that seems to be
usable and meat mine and others requirements (not that I'm not saying it=

cannot be improved -- I'm always happy to hear comments) and now I'm
starting to concentrate on the reusing of the grabbed memory.  At first
I wasn't sure how this can be managed but thanks to many comments
(including yours, thanks!) I have an idea of how the thing should work
and what I should do from now.

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
