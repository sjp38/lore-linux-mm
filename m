Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B7D376B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 04:36:32 -0500 (EST)
Message-ID: <4B8F7F1A.6020000@cn.fujitsu.com>
Date: Thu, 04 Mar 2010 17:36:26 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and mems_allowed
References: <4B8E3F77.6070201@cn.fujitsu.com> <20100304033017.GN8653@laptop>
In-Reply-To: <20100304033017.GN8653@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-4 11:30, Nick Piggin wrote:
> On Wed, Mar 03, 2010 at 06:52:39PM +0800, Miao Xie wrote:
>> if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_allowed or mems_allowed in
>> task->mempolicy are not atomic operations, and the kernel page allocator gets an empty
>> mems_allowed when updating task->mems_allowed or mems_allowed in task->mempolicy. So we
>> use a rwlock to protect them to fix this probelm.
> 
> Thanks for working on this. However, rwlocks are pretty nasty to use
> when you have short critical sections and hot read-side (they're twice
> as heavy as even spinlocks in that case).
> 
> It's being used in the page allocator path, so I would say rwlocks are
> almost a showstopper. Wouldn't it be possible to use a seqlock for this?
> 

I will do my best to try to do it.

Thanks!
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
