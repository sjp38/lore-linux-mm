Date: Tue, 31 Dec 2002 11:02:30 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: shpte scheduling-inside-spinlock bug
Message-ID: <62480000.1041354150@[10.1.1.5]>
In-Reply-To: <3E0ECC02.6CEBD613@digeo.com>
References: <3E0ECC02.6CEBD613@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Sunday, December 29, 2002 02:18:42 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> We would like to not hold i_shared_lock across the zap_pte_range() call
> anyway, for scheduling latency reasons.
> 
> But I suspect that i_shared_lock is the only thing which prevents the
> vma from disappearing while truncate is playing with it.
> 
> umm...  I think we can just turn i_shared_lock into a semaphore.  Nests
> inside mmap_sem.

I've stared at this for a couple of days and don't see any better solution.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
