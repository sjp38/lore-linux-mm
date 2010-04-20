Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC6686B01F1
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 09:43:26 -0400 (EDT)
Date: Tue, 20 Apr 2010 15:43:22 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: accessing stack of non-current task
Message-ID: <20100420134322.GM20640@cmpxchg.org>
References: <y2t448a67a1004200538l45d46338vcd77b63a0e53d54e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <y2t448a67a1004200538l45d46338vcd77b63a0e53d54e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Uma shankar <shankar.vk@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 06:08:14PM +0530, Uma shankar wrote:
> Hi,
> 
> Is it possible for the kernel to access the user-stack data of a
> task different from "current" ? ( This is needed for stack-dump as
> well as backtrace. )

Yes, have a look at __get_user_pages() in mm/memory.c.

> I thought the answer is "no". ( Kernel sees memory through the
> page-table of "current" )

That is correct when using virtual addresses and letting the MMU
do the page table lookup in the currently active page tables.

But if you have the task_struct of another process, you can easily
get to its vmas and page tables (task->mm) and walk them in software.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
