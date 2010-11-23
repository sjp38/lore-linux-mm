Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 78ABA6B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 10:45:24 -0500 (EST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LCC007AEH1OTI50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 23 Nov 2010 15:44:12 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LCC00LGCH1NMM@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 23 Nov 2010 15:44:12 +0000 (GMT)
Date: Tue, 23 Nov 2010 16:44:11 +0100
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 0/4] big chunk memory allocator v4
In-reply-to: 
 <F4DF93C7785E2549970341072BC32CD796018FCB@irsmsx503.ger.corp.intel.com>
Message-id: <op.vmmrbxp57p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
 <20101119125653.16dd5452.akpm@linux-foundation.org>
 <F4DF93C7785E2549970341072BC32CD796018FCB@irsmsx503.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kleen, Andi" <andi.kleen@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Bob Liu <lliubbo@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "pawel@osciak.com" <pawel@osciak.com>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 09:59:57 +0100, Kleen, Andi <andi.kleen@intel.com> w=
rote:

>> >   But yes, because of fragmentation, this cannot guarantee 100%
>> alloc.
>> >   If alloc_contig_pages() is called in system boot up or movable_zo=
ne
>> is used,
>> >   this allocation succeeds at high rate.
>>
>> So this is an alternatve implementation for the functionality offered=

>> by Michal's "The Contiguous Memory Allocator framework".
>
> I see them more as orthogonal: Michal's code relies on preallocation
> and manages the memory after that.

Yes and no.  The v6 version adds not-yet-finished support for sharing
the preallocated blocks with page allocator (so if CMA is not using the
memory, page allocator can allocate it, and when CMA finally wants to
use it the allocated pages are migrated).

In the v6 implementation I have added a new migration type (I cannot see=
m
to find who proposed such approach first).  When I'll end debugging the
code I'll try to work things out without adding additional entity (that
is new migration type).

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
