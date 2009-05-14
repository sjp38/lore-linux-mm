Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 851E76B01E5
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:10:08 -0400 (EDT)
Subject: Re: [PATCH] Physical Memory Management [0/1]
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090514100718.d8c20b64.akpm@linux-foundation.org>
References: <op.utu26hq77p4s8u@amdc030>
	 <20090513151142.5d166b92.akpm@linux-foundation.org>
	 <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop>
	 <op.utw4fdhz7p4s8u@amdc030> <1242302702.6642.1140.camel@laptop>
	 <op.utw7yhv67p4s8u@amdc030>
	 <20090514100718.d8c20b64.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 14 May 2009 19:10:00 +0200
Message-Id: <1242321000.6642.1456.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Micha__ Nazarewicz <m.nazarewicz@samsung.com>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-05-14 at 10:07 -0700, Andrew Morton wrote:
> On Thu, 14 May 2009 15:04:55 +0200
> Micha__ Nazarewicz <m.nazarewicz@samsung.com> wrote:
> 
> > On Thu, 14 May 2009 14:05:02 +0200, Peter Zijlstra wrote:
> > > And who says your pre-allocated pool won't fragment with repeated PMM
> > > use?
> > 
> > Yes, this is a good question.  What's more, there's no good answer. ;)
> > 
> 
> We do have capability in page reclaim to deliberately free up
> physically contiguous pages (known as "lumpy reclaim").
> 
> It would be interesting were someone to have a go at making that
> available to userspace: ask the kernel to give you 1MB of physically
> contiguous memory.  There are reasons why this can fail, but migrating
> pages can be used to improve the success rate, and userspace can be
> careful to not go nuts using mlock(), etc.
> 
> The returned memory would of course need to be protected from other
> reclaim/migration/etc activity.

I thought we already exposed this, its called hugetlbfs ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
