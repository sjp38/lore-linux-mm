Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 676B46B0135
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 03:07:44 -0400 (EDT)
Date: Thu, 14 Oct 2010 16:07:12 +0900
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <87sk0a1sq0.fsf@basil.nowhere.org>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<87sk0a1sq0.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20101014160217N.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: andi@firstfloor.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010 09:01:43 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> >
> > What this wants to do: 
> >   allocates a contiguous chunk of pages larger than MAX_ORDER.
> >   for device drivers (camera? etc..)
> 
> I think to really move forward you need a concrete use case
> actually implemented in tree.

As already pointed out, some embeded drivers need physcailly
contignous memory. Currenlty, they use hacky tricks (e.g. playing with
the boot memory allocators). There are several proposals for this like
adding a new kernel memory allocator (from samsung).

It's ideal if the memory allocator can handle this, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
