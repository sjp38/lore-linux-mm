Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B86906B01A5
	for <linux-mm@kvack.org>; Thu, 14 May 2009 07:48:04 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KJM00AJUU5BU3@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 14 May 2009 12:48:47 +0100 (BST)
Received: from amdc030 ([106.116.37.122])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0KJM00D7XU54YB@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 14 May 2009 12:48:47 +0100 (BST)
Date: Thu, 14 May 2009 13:48:39 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH] Physical Memory Management [0/1]
In-reply-to: <1242300002.6642.1091.camel@laptop>
Message-id: <op.utw4fdhz7p4s8u@amdc030>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 8BIT
References: <op.utu26hq77p4s8u@amdc030>
 <20090513151142.5d166b92.akpm@linux-foundation.org>
 <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 2009-05-14 at 11:00 +0200, MichaA? Nazarewicz wrote:
>>   PMM solves this problem since the buffers are allocated when they
>>   are needed.

On Thu, 14 May 2009 13:20:02 +0200, Peter Zijlstra wrote:
> Ha - only when you actually manage to allocate things. Physically
> contiguous allocations are exceedingly hard once the machine has been
> running for a while.

PMM reserves memory during boot time using alloc_bootmem_low_pages().
After this is done, it can allocate buffers from reserved pool.

The idea here is that there are n hardware accelerators, each
can operate on 1MiB blocks (to simplify assume that's the case).
However, we know that at most m < n devices will be used at the same
time so instead of reserving n MiBs of memory we reserve only m MiBs.

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
