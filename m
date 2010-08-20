Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC136B02D4
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 02:58:15 -0400 (EDT)
Date: Fri, 20 Aug 2010 15:57:51 +0900
Subject: Re: [PATCH/RFCv3 0/6] The Contiguous Memory Allocator framework
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <op.vhp4pws27p4s8u@localhost>
References: <op.vhppgaxq7p4s8u@localhost>
	<20100820121124Z.fujita.tomonori@lab.ntt.co.jp>
	<op.vhp4pws27p4s8u@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100820155617S.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: m.nazarewicz@samsung.com
Cc: fujita.tomonori@lab.ntt.co.jp, kyungmin.park@samsung.com, linux-mm@kvack.org, dwalker@codeaurora.org, linux@arm.linux.org.uk, corbet@lwn.net, p.osciak@samsung.com, broonie@opensource.wolfsonmicro.com, linux-kernel@vger.kernel.org, hvaibhav@ti.com, hverkuil@xs4all.nl, kgene.kim@samsung.com, zpfeffer@codeaurora.org, jaeryul.oh@samsung.com, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 08:38:10 +0200
**UNKNOWN CHARSET** <m.nazarewicz@samsung.com> wrote:

> On Fri, 20 Aug 2010 05:12:50 +0200, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> >> 1. Integration on API level meaning that some kind of existing API is used
> >>     instead of new cma_*() calls.  CMA adds notion of devices and memory
> >>     types which is new to all the other APIs (coherent has notion of devices
> >>     but that's not enough).  This basically means that no existing API can be
> >>     used for CMA.  On the other hand, removing notion of devices and memory
> >>     types would defeat the whole purpose of CMA thus destroying the solution
> >>     that CMA provides.
> >
> > You can create something similar to the existing API for memory
> > allocator.
> 
> That may be tricky.  cma_alloc() takes four parameters each of which is
> required for CMA.  No other existing set of API uses all those arguments.
> This means, CMA needs it's own, somehow unique API.  I don't quite see
> how the APIs may be unified or "made similar".  Of course, I'm gladly
> accepting suggestions.

Have you even tried to search 'blk_kmalloc' on google? I wrote
"similar to the existing API', not "reuse the existing API".


> >> 2. Reuse of memory pools meaning that memory reserved by CMA can then be
> >>     used by other allocation mechanisms.  This is of course possible.  For
> >>     instance coherent could easily be implemented as a wrapper to CMA.
> >>     This is doable and can be done in the future after CMA gets more
> >>     recognition.
> >>
> >> 3. Reuse of algorithms meaning that allocation algorithms used by other
> >>     allocators will be used with CMA regions.  This is doable as well and
> >>     can be done in the future.
> >
> > Well, why can't we do the above before the inclusion?
> 
> Because it's quite a bit of work and instead of diverting my attention I'd
> prefer to make CMA as good as possible and then integrate it with other
> subsystems.  Also, adding the integration would change the patch from being
> 4k lines to being like 40k lines.

4k to 40k? I'm not sure. But If I see something like the following, I
suspect that there is a better way to integrate this into the existing
infrastructure.

mm/cma-best-fit.c                   |  407 +++++++++++++++

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
