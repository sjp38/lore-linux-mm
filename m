From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Message-Id: <200101141915.f0EJF0508827@flint.arm.linux.org.uk>
Subject: Re: exit_mmap()
Date: Sun, 14 Jan 2001 19:15:00 +0000 (GMT)
In-Reply-To: <Pine.OSF.4.21.0101150424360.24789-100000@paulaner.disy.cse.unsw.EDU.AU> from "Adam 'WeirdArms' Wiggins" at Jan 15, 2001 04:55:24 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.EDU.AU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(About 2.4 kernels)

Adam 'WeirdArms' Wiggins writes:
> The function exit_mmap() in linux/mm/mmap.c does something that I can't
> figure. The function as far as I can tell loops on each vm_area_struct of
> the mm_struct to tear them down. What I don't understand is that while
> doing this if calls flush_cache_range() on the range covered by the
> vm_area_struct. exit_mmap() is called by exec_mmap() in linux/fs/exec.c
> (which calls flush_cache_mm() before exit_mmap() already) and by 
> mmput() in linux/kernel/fork.c
> 
> Why does exit_mmap() not just call flush_cache_mm() before the while
> loop?

I've CC:'d this to the linux-mm list, and taken the linux-arm-kernel off
the CC: list.

People on linux-mm: please note that neither Adam nor myself are subscribed
to linux-mm.
   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |        Russell King       linux@arm.linux.org.uk      --- ---
  | | | |            http://www.arm.linux.org.uk/            /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
