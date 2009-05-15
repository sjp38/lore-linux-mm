Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0C3E06B0098
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:05:28 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KJO00IMGPKW3L@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 15 May 2009 13:05:20 +0100 (BST)
Received: from amdc030 ([106.116.37.122])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0KJO00GM9PKUMN@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2009 13:05:20 +0100 (BST)
Date: Fri, 15 May 2009 14:05:17 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH] Physical Memory Management [0/1]
In-reply-to: <20090515112656.GD16682@one.firstfloor.org>
Message-id: <op.utyzu3ot7p4s8u@amdc030>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 8BIT
References: <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop>
 <op.utw4fdhz7p4s8u@amdc030> <1242302702.6642.1140.camel@laptop>
 <op.utw7yhv67p4s8u@amdc030>
 <20090514100718.d8c20b64.akpm@linux-foundation.org>
 <1242321000.6642.1456.camel@laptop> <op.utyudge07p4s8u@amdc030>
 <20090515101811.GC16682@one.firstfloor.org> <op.utyv89ek7p4s8u@amdc030>
 <20090515112656.GD16682@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>> On Fri, 15 May 2009 12:18:11 +0200, Andi Kleen wrote:
>>> However for non fragmentation purposes you probably don't
>>> want too many different sizes anyways, the more sizes, the worse
>>> the fragmentation. Ideal is only a single size.

> On Fri, May 15, 2009 at 12:47:23PM +0200, MichaA? Nazarewicz wrote:
>> Unfortunately, sizes may very from several KiBs to a few MiBs.

On Fri, 15 May 2009 13:26:56 +0200, Andi Kleen <andi@firstfloor.org> wrote:
> Then your approach will likely not be reliable.

>> On the other hand, only a handful of apps will use PMM in our system
>> and at most two or three will be run at the same time so hopefully
>> fragmentation won't be so bad.  But yes, I admit it is a concern.
>
> Such tight restrictions might work for you, but for mainline Linux the  
> quality standards are higher.

I understand PMM in current form may be unacceptable, however, hear me
out and please do correct me if I'm wrong at any point as I would love
to use an existing solution if any fulfilling my needs is present:

When different sizes of buffers are needed fragmentation is even bigger
problem in hugetlb (as pages must be aligned) then with PMM.

If a buffer that does not match page size is needed then with hugetlb
either bigger page needs to be allocated (and memory wasted) or few
smaller need to be merged (and the same problem as in PMM exists --
finding contiguous pages).

Reclaiming is not really an option since situation where there is no
sane bound time for allocation is not acceptable -- you don't want to
wait 10 seconds for an application to start on your cell phone. ;)

Also, I need an ability to convert any buffer to a Sys V shm, as to
be able to pass it to X server.  Currently no such API exist, does it?

With PMM and it's notion of memory types, different allocators and/or
memory pools, etc.  Allocators could be even dynamically loaded as
modules if one desires that.  My point is, that PMM is to be considered
a framework for situations similar to the one I described thorough all
of my mails, rather then a universal solution.

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
