From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200011142051.MAA81386@google.engr.sgi.com>
Subject: Re: Question about pte_alloc()
Date: Tue, 14 Nov 2000 12:51:12 -0800 (PST)
In-Reply-To: <3A12363A.3B5395AF@cse.iitkgp.ernet.in> from "Shuvabrata Ganguly" at Nov 15, 2000 02:07:38 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
Cc: linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> hi all,
> 
> it appears from the code that pte_alloc() might block since it allocates
> a page table with GFP_KERNEL if the page table doesnt already exist. i
> need to call pte_alloc() at interrupt time. Basically i want to map some
> kernel memory into user space as soon as the device gives me data. will
> there be any problem if i use another version of pte_alloc() which calls
> with GFP_ATOMIC priority?
> Maybe i am completely lost :-)

Why do you want to run the risk of failing in your allocation at intr
time? 

A cleaner thing to do is to allocate vma/memory/pagetables at driver 
mmap/fcntl time. If you must make the user program fault before your
device will give data (although this synchronization is probably better
done other ways), mark the ptes invalid ... then mark them valid when 
you get the data in your intr routine ... of course, you *might* want 
to flush tlbs on other processors too in that case.

Kanoj

> 
> cheers
> joy
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
