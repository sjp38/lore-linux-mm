Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4763A6B0092
	for <linux-mm@kvack.org>; Fri, 15 May 2009 07:11:49 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KJO00ETAN3NPL@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 15 May 2009 12:11:47 +0100 (BST)
Received: from amdc030 ([106.116.37.122])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0KJO00B7JN3L9T@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2009 12:11:47 +0100 (BST)
Date: Fri, 15 May 2009 13:11:44 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH] Physical Memory Management [0/1]
In-reply-to: <1242385414.26820.55.camel@twins>
Message-id: <op.utyxdu2j7p4s8u@amdc030>
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
 <20090515101811.GC16682@one.firstfloor.org> <op.utyv89ek7p4s8u@amdc030>
 <1242385414.26820.55.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 2009-05-15 at 12:47 +0200, MichaA? Nazarewicz wrote:
>> I cannot create a huge page SysV shared memory segment
>> with pages of specified size, can I?

On Fri, 15 May 2009 13:03:34 +0200, Peter Zijlstra wrote:
> Well, hugetlbfs is a fs, so you can simply create a file on there and
> map that shared -- much saner interface than sysvshm if you ask me.

It's not a question of being sane or not, it's a question of whether
X server supports it and it doesn't.  X can read data from Sys V shm
to avoid needles copying (or sending via unix socket or whatever)
pixmaps (or whatever) and so PMM lets it read from continuous blocks
without knowing or carying about it.

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
