Message-ID: <3CAD774C.3010908@earthlink.net>
Date: Fri, 05 Apr 2002 10:07:08 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: How CPU(x86) resolve kernel address
References: <Pine.GSO.4.10.10204051648440.18364-100000@mailhub.cdac.ernet.in>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sanket Rathi wrote:

> I read all about the memory management in linux. all thing are clear to me
> like there is 3GB space for user procee and 1GB for kernel and thats why
> kernel address always greater then 0xC0000000. But one thing is not clear
> that is for kernel address there is no page table,


Yes there is. Look for swapper_pg_dir. It maps physical address
N to virtual address PAGE_OFFSET+N.

> actually there is no
> need because this is one to one mapping to physical memory but who resolve
> kernel address to actual physical address how CPU(X86) perform this task
> because when we do DMA we have to give actual physical address by
> virt_to_phys() so what is the mechanism by which CPU translate kernel
> address into physical address ( Somewhere i heard that CPU ignore some of
> the upper bits of address if so then how much bits and why).


I don't think so. Kernel and user addresses all pass through
the virtual mapping mechanism. virt_to_phys() just subtracts
PAGE_OFFSET from the kernel virtual address to arrive at the
physical address

Cheers,


-- Joe
   Using open-source software: free.
   Pissing Bill Gates off: priceless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
