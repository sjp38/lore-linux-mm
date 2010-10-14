Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 708EC6B0172
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:24:19 -0400 (EDT)
Date: Fri, 15 Oct 2010 00:24:05 +0900
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <AANLkTin-8mjL_B8g9cPoviQU0FUaEyb_v5_Fm4kbSweA@mail.gmail.com>
References: <87sk0a1sq0.fsf@basil.nowhere.org>
	<20101014160217N.fujita.tomonori@lab.ntt.co.jp>
	<AANLkTin-8mjL_B8g9cPoviQU0FUaEyb_v5_Fm4kbSweA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20101015001904I.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: felipe.contreras@gmail.com
Cc: fujita.tomonori@lab.ntt.co.jp, andi@firstfloor.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Oct 2010 15:09:13 +0300
Felipe Contreras <felipe.contreras@gmail.com> wrote:

> > As already pointed out, some embeded drivers need physcailly
> > contignous memory. Currenlty, they use hacky tricks (e.g. playing with
> > the boot memory allocators). There are several proposals for this like
> > adding a new kernel memory allocator (from samsung).
> >
> > It's ideal if the memory allocator can handle this, I think.
> 
> Not only contiguous, but sometimes also coherent.

Can you give the list of such drivers?

Anyway, in general cases, the page allocator needs to allocate large
contignous memory if we want dma_alloc_coherent to return large
contignous coherent memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
