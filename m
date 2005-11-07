Message-ID: <436F29BF.3010804@yahoo.com.au>
Date: Mon, 07 Nov 2005 21:17:35 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	<20051106124944.0b2ccca1.pj@sgi.com>	<436EC2AF.4020202@yahoo.com.au>	<200511070442.58876.ak@suse.de>	<20051106203717.58c3eed0.pj@sgi.com>	<436EEF43.2050403@yahoo.com.au> <20051107014659.14c2631b.pj@sgi.com>
In-Reply-To: <20051107014659.14c2631b.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: ak@suse.de, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Nick wrote:

>>>And is the pair of operators:
>>>  task_lock(current), task_unlock(current)
>>>really that much worse than the pair of operators
>>>  ...
>>>  preempt_disable, preempt_enable
> 
> 
> That part still surprises me a little.  Is there enough difference in
> the performance between:
> 
>   1) task_lock, which is a spinlock on current->alloc_lock and
>   2) rcu_read_lock, which is .preempt_count++; barrier()
> 
> to justify a separate slab cache for cpusets and a little more code?
> 
> For all I know (not much) the task_lock might actually be cheaper ;).
> 

But on a preempt kernel the spinlock must disable preempt as well!

Not to mention that a spinlock is an atomic op (though that is getting
cheaper these days) + 2 memory barriers (getting more expensive).

> The semaphore down means doing an atomic_dec_return(), which imposes
> a memory barrier, right?
> 

Yep.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
