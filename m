Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6236B007E
	for <linux-mm@kvack.org>; Fri, 15 May 2009 06:12:32 -0400 (EDT)
Date: Fri, 15 May 2009 12:18:11 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Physical Memory Management [0/1]
Message-ID: <20090515101811.GC16682@one.firstfloor.org>
References: <op.utu26hq77p4s8u@amdc030> <20090513151142.5d166b92.akpm@linux-foundation.org> <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop> <op.utw4fdhz7p4s8u@amdc030> <1242302702.6642.1140.camel@laptop> <op.utw7yhv67p4s8u@amdc030> <20090514100718.d8c20b64.akpm@linux-foundation.org> <1242321000.6642.1456.camel@laptop> <op.utyudge07p4s8u@amdc030>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.utyudge07p4s8u@amdc030>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Correct me if I'm wrong, but if I understand correctly, currently only
> one size of huge page may be defined, even if underlaying architecture

That's not correct, support for multiple huge page sizes was recently
added. The interface is a bit clumpsy admittedly, but it's there.

However for non fragmentation purposes you probably don't
want too many different sizes anyways, the more sizes, the worse
the fragmentation. Ideal is only a single size.

> largest blocks that may ever be requested and then waste a lot of
> memory when small pages are requested or (ii) define smaller huge
> page size but then special handling of large regions need to be
> implemented.

If you don't do that then long term fragmentation will
kill you anyways. it's easy to show that pre allocation with lots
of different sizes is about equivalent what the main page allocator
does anyways.

> So to sum up, if I understand everything correctly, hugetlb would be a
> great solution when working with buffers of similar sizes.  However, it's
> not so good when size of requested buffer may vary greatly.

As Peter et.al. explained earlier varying buffer sizes don't work
anyways.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
