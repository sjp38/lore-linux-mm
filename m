Subject: Re: Non-Contiguous Memory Allocation Tests
Message-ID: <OF3FECDB70.6DC3683E-ON86256DF8.0050199B@raytheon.com>
From: Mark_H_Johnson@Raytheon.com
Date: Wed, 10 Dec 2003 08:42:15 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ruthiano Simioni Munaretti <ruthiano@exatas.unisinos.br>
Cc: linux-mm@kvack.org, owner-linux-mm@kvack.org, sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>




>In VGNCA, the main idea is enable/disable interrupts only one time,
reducing
>this overhead. Also, VGNCA allocation/deallocation functions are a little
>more simple, because elimination of unnecessary test conditions in size
>allocation.
>
>Our patch is intended to be a test to check if this could bring enough
>benefits to deserve a more careful implementation. We also included some
code
>to benchmark allocations and deallocations, using the RDTSC instruction.

My only comment about this (and similar "optimizations") is a general
concern about latency. Let's say I have an interactive (or real time)
program running and some other application does one of these non
contiguous memory allocations. Is the time to complete the allocation
bounded? Not apparently since "numpages" is an input to the allocation
routine. There also does not appear to be any code to allow a reschedule
to occur if scheduling is needed. If you are serious about pursuing
something like this, I suggest you review the lock break / preemption
code in the kernel (or in Andrew Morton's low latency patches) for
examples of the required coding style.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
