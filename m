Received: from twcny.rr.com (bsh1-12d.twcny.rr.com [24.92.245.45])
	by mailout2-0.nyroc.rr.com (8.9.3/8.9.3) with ESMTP id WAA29744
	for <linux-mm@kvack.org>; Tue, 8 Aug 2000 22:29:26 -0400 (EDT)
Message-ID: <3990C388.64AE497D@twcny.rr.com>
Date: Tue, 08 Aug 2000 22:35:52 -0400
From: Assem Salama <assem@twcny.rr.com>
Reply-To: assem@twcny.rr.com
MIME-Version: 1.0
Subject: Kernel Question
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am runing RedHat 6.2, kernel version: 2.2.14-5.0

I have a couple of questions:
    When I try to use ioremap, it gives me an undefined refernce. So, I
ended up using __ioremap. Is this the right way? Am I missing something?

same thing happened with memcpy, and virt_to_phys.

    Also, I have a PCI board with 16MB of onboard memory. I got the
driver to probe the device and everything. I used __ioremap to remap the

PCI memory into virtual memory and I can read and write to it in kernel
space. Now, I want to be able to do that through user space. So, I
implemented mmap into my driver. I use remap_page_range with the
following arguments:

in init_mdoule()
myri_phys = (unsigned long) dev->base_address[0] &
PCI_BASE_ADDRESS_MEM_MASK;
...

in mydrv_mmap()
remap_page_range(vmP->vm_start, myri_phys,16*1024*1024 /* 16MB */,
vmP->vm_page_prot)

however, when I call mmap from user space, the machine either hangs or
completely reboots.

Any help would be greatly appreciated.
Sincerely,
Assem Salama

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
