Received: from localhost (sanket@localhost)
	by mailhub.cdac.ernet.in (8.11.4/8.11.4) with ESMTP id g35BRug18836
	for <linux-mm@kvack.org>; Fri, 5 Apr 2002 16:57:59 +0530 (IST)
Date: Fri, 5 Apr 2002 16:57:56 +0530 (IST)
From: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Subject: How CPU(x86) resolve kernel address
Message-ID: <Pine.GSO.4.10.10204051648440.18364-100000@mailhub.cdac.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I read all about the memory management in linux. all thing are clear to me
like there is 3GB space for user procee and 1GB for kernel and thats why
kernel address always greater then 0xC0000000. But one thing is not clear
that is for kernel address there is no page table, actually there is no
need because this is one to one mapping to physical memory but who resolve
kernel address to actual physical address how CPU(X86) perform this task
because when we do DMA we have to give actual physical address by
virt_to_phys() so what is the mechanism by which CPU translate kernel
address into physical address ( Somewhere i heard that CPU ignore some of
the upper bits of address if so then how much bits and why).

Thanks in advance 

--- Sanket Rathi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
