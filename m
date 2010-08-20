Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F10336B02B1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 23:13:34 -0400 (EDT)
Date: Fri, 20 Aug 2010 12:12:50 +0900
Subject: Re: [PATCH/RFCv3 0/6] The Contiguous Memory Allocator framework
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <op.vhppgaxq7p4s8u@localhost>
References: <AANLkTikp49oOny-vrtRTsJvA3Sps08=w7__JjdA3FE8t@mail.gmail.com>
	<20100820001339N.fujita.tomonori@lab.ntt.co.jp>
	<op.vhppgaxq7p4s8u@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100820121124Z.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: m.nazarewicz@samsung.com
Cc: kyungmin.park@samsung.com, fujita.tomonori@lab.ntt.co.jp, linux-mm@kvack.org, dwalker@codeaurora.org, linux@arm.linux.org.uk, corbet@lwn.net, p.osciak@samsung.com, broonie@opensource.wolfsonmicro.com, linux-kernel@vger.kernel.org, hvaibhav@ti.com, hverkuil@xs4all.nl, kgene.kim@samsung.com, zpfeffer@codeaurora.org, jaeryul.oh@samsung.com, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com
List-ID: <linux-mm.kvack.org>

> >> We hope this method included at mainline kernel if possible.
> >> It's really needed feature for our multimedia frameworks.
> >
> > You got any comments from mm people?
> >
> > Virtually, this adds a new memory allocator implementation that steals
> > some memory from memory allocator during boot process. Its API looks
> > completely different from the API for memory allocator. That doesn't
> > sound appealing to me much. This stuff couldn't be integrated well
> > into memory allocator?
> 
> What kind of integration do you mean?  I see three levels:
> 
> 1. Integration on API level meaning that some kind of existing API is used
>     instead of new cma_*() calls.  CMA adds notion of devices and memory
>     types which is new to all the other APIs (coherent has notion of devices
>     but that's not enough).  This basically means that no existing API can be
>     used for CMA.  On the other hand, removing notion of devices and memory
>     types would defeat the whole purpose of CMA thus destroying the solution
>     that CMA provides.

You can create something similar to the existing API for memory
allocator.

For example, blk_kmalloc/blk_alloc_pages was proposed as memory
allocator API with notion of an address range for allocated memory. It
wasn't merged for other reasons though.

I don't mean that this is necessary for the inclusion (I'm not the
person to ack or nack this). I just expect the similarity of memory
allocator API.


> 2. Reuse of memory pools meaning that memory reserved by CMA can then be
>     used by other allocation mechanisms.  This is of course possible.  For
>     instance coherent could easily be implemented as a wrapper to CMA.
>     This is doable and can be done in the future after CMA gets more
>     recognition.
> 
> 3. Reuse of algorithms meaning that allocation algorithms used by other
>     allocators will be used with CMA regions.  This is doable as well and
>     can be done in the future.

Well, why can't we do the above before the inclusion?

Anyway, I think that comments from mm people would be helpful to merge
this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
