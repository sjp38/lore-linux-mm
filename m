Message-ID: <432A3810.9070600@yahoo.com.au>
Date: Fri, 16 Sep 2005 13:12:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: New lockless pagecache
References: <4317F071.1070403@yahoo.com.au> <4317F50B.6080005@yahoo.com.au> <35f686220509151250e598fda@mail.gmail.com>
In-Reply-To: <35f686220509151250e598fda@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alokkataria1@gmail.com
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Alok kataria wrote:
> Hi Nick,
> 
> I have collected performance numbers for the lock less page cache
> patch on the AIM - IO test.
> The performance numbers are collected for 1-100 tasks 1-50 tasks and
> 90-100 tasks  both for with and without your patch. This was done on
> 2.6.13 kernel.
> There's definite improvement when the tasks are small i.e ~50-70. But
> when the tasks go beyond 80, we see a large performance dip.
> I again profiled the 90-100 runs with spinlock's inlined, but couldn't
> understand the reason behind the performance difference.
> 
> Please find attached the performance numbers as well as the oprofile logs.
> 

Hi Alok,

Thanks very much for doing these numbers. Performance is improved
significantly at smaller numbers of tasks, as you say.

Unfortunately I can't pinpoint the reason why performance drops at
larger numbers. I could assume that the last remaining place that
used read_lock_irq for the tree_lock (wait_on_page_writeback_range)
got hurt when switching to spinlocks, but that would seem vary
unlikely.

I'll have to look into it further.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
