Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A0F826B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 15:40:13 -0500 (EST)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1NkkGe-000852-Dk
	for linux-mm@kvack.org; Thu, 25 Feb 2010 21:25:04 +0100
Received: from 85-222-76-212.home.aster.pl ([85.222.76.212])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 21:25:04 +0100
Received: from zenblu by 85-222-76-212.home.aster.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 21:25:04 +0100
From: Zenek <zenblu@wp.pl>
Subject: vmapping user pages - feasible?
Date: Thu, 25 Feb 2010 20:05:14 +0000 (UTC)
Message-ID: <hm6l5q$rqp$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

my kernel driver gets a userspace pointer to a memory area (virtually 
contiguous), allocated by userspace. I would like to use that memory in a 
vmalloc-like manner, i.e. I want it to be:

- accessible from kernel
- contiguous in virtual address space
- I may need access from interrupt context as well.

I will be writing to it using the CPU only, in kernel mode.

I understand that:
- no page pinning is required (as only the CPU will be writing to that 
area)
- I would be able to use that memory even directly without vmapping, but 
only if I didn't want to access it from interrupt context and as long as 
it'd be mapped below highmem?

There will be no multithreaded access to that memory.

If the userspace free()s the memory, I still have the pages unless I 
vunmap() them, right?

How should I go about it? Get the user's vm_area_struct, go through all 
the pages, construct an array of struct *page and vmap it?

Thank you!
Zenek Blus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
