Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C7F206B020B
	for <linux-mm@kvack.org>; Wed, 12 May 2010 04:59:26 -0400 (EDT)
Message-ID: <4BEA6E3D.10503@cn.fujitsu.com>
Date: Wed, 12 May 2010 17:00:45 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] cpuset,mm: fix no node to alloc memory when changing
 cpuset's mems - fix2
References: <4BEA56D3.6040705@cn.fujitsu.com> <20100512003246.9f0ee03c.akpm@linux-foundation.org>
In-Reply-To: <20100512003246.9f0ee03c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-5-12 12:32, Andrew Morton wrote:
> On Wed, 12 May 2010 15:20:51 +0800 Miao Xie <miaox@cn.fujitsu.com> wrote:
> 
>> @@ -985,6 +984,7 @@ repeat:
>>  	 * for the read-side.
>>  	 */
>>  	while (ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
>> +		task_unlock(tsk);
>>  		if (!task_curr(tsk))
>>  			yield();
>>  		goto repeat;
> 
> Oh, I meant to mention that.  No yield()s, please.  Their duration is
> highly unpredictable.  Can we do something more deterministic here?

Maybe we can use wait_for_completion().

> 
> Did you consider doing all this with locking?  get_mems_allowed() does
> mutex_lock(current->lock)?

do you means using a real lock(such as: mutex) to protect mempolicy and mem_allowed?

It may cause the performance regression, so I do my best to abstain from using a real
lock.

Thanks
Miao

> 
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
