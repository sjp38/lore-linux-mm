Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8CD2D6B0082
	for <linux-mm@kvack.org>; Fri, 15 May 2009 06:46:55 -0400 (EDT)
Received: from eu_spt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KJO0005CLZ2H1@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 15 May 2009 11:47:26 +0100 (BST)
Received: from amdc030 ([106.116.37.122])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0KJO00JSELZ0FU@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2009 11:47:26 +0100 (BST)
Date: Fri, 15 May 2009 12:47:23 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH] Physical Memory Management [0/1]
In-reply-to: <20090515101811.GC16682@one.firstfloor.org>
Message-id: <op.utyv89ek7p4s8u@amdc030>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 8BIT
References: <op.utu26hq77p4s8u@amdc030>
 <20090513151142.5d166b92.akpm@linux-foundation.org>
 <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop>
 <op.utw4fdhz7p4s8u@amdc030> <1242302702.6642.1140.camel@laptop>
 <op.utw7yhv67p4s8u@amdc030>
 <20090514100718.d8c20b64.akpm@linux-foundation.org>
 <1242321000.6642.1456.camel@laptop> <op.utyudge07p4s8u@amdc030>
 <20090515101811.GC16682@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Correct me if I'm wrong, but if I understand correctly, currently only
>> one size of huge page may be defined, even if underlaying architecture

On Fri, 15 May 2009 12:18:11 +0200, Andi Kleen wrote:
> That's not correct, support for multiple huge page sizes was recently
> added. The interface is a bit clumpsy admittedly, but it's there.

I'll have to look into that further then.  Having said that, I cannot
create a huge page SysV shared memory segment with pages of specified
size, can I?

> However for non fragmentation purposes you probably don't
> want too many different sizes anyways, the more sizes, the worse
> the fragmentation. Ideal is only a single size.

Unfortunately, sizes may very from several KiBs to a few MiBs.
On the other hand, only a handful of apps will use PMM in our system
and at most two or three will be run at the same time so hopefully
fragmentation won't be so bad.  But yes, I admit it is a concern.

>> largest blocks that may ever be requested and then waste a lot of
>> memory when small pages are requested or (ii) define smaller huge
>> page size but then special handling of large regions need to be
>> implemented.
>
> If you don't do that then long term fragmentation will
> kill you anyways. it's easy to show that pre allocation with lots
> of different sizes is about equivalent what the main page allocator
> does anyways.

However, having an allocator in PMM used by a handful of apps, an
architect may provide a use cases that need to be supported and then
PMM may be reimplemented to guarantee that those cases are handled.

> As Peter et.al. explained earlier varying buffer sizes don't work
> anyways.

Either I missed something or Peter and Adrew only pointed the problem
we all seem to agree exists: a problem of fragmentation.

-- 
Best regards,                                            _     _
 .o. | Liege of Serenly Enlightened Majesty of         o' \,=./ `o
 ..o | Computer Science,  MichaA? "mina86" Nazarewicz      (o o)
 ooo +-<m.nazarewicz@samsung.com>-<mina86@jabber.org>-ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
