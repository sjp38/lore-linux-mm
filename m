Message-ID: <20041210034848.4490.qmail@web53909.mail.yahoo.com>
Date: Thu, 9 Dec 2004 19:48:48 -0800 (PST)
From: Fawad Lateef <fawad_lateef@yahoo.com>
Subject: Re: Re: Plzz help me regarding HIGHMEM (PAE) confusion in Linux-2.4 ???
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- William Lee Irwin III <wli@holomorphy.com> wrote:

> The pgd is not loaded into %cr3, only its address.
> 

Ya, right, Actually I mis-understood that. Thanks for
clearing.

> 
> There is only one kernel address space. You are
> probably actually
> trying to write blkdev-highmem, but it would be far
> easier to populate
> a ramfs at boot instead of using a ramdisk.
> 

Is the kmap_atomic fails due to a single address space
of kernel ??? If not then y kmap is failing in my
case. I m actually writing a simple RAMDISK but the
RAM it is using is the HIGHMEM and I already reserved
all the HIGHMEM for me by changing in
arch/i386/mm/init.c in one_highpage_init function, I
wrote 

if((unsigned long)(page-mem_map) >= 0x100000) (
      SetPageReserved(page);
      set_bit(PG_highmem, &page->flags);
      atomic_set(&page->count, 1);
      totalhigh_pages++;
      return;
}

Is reserving mem through this way is wrong ??? And is
it creating problem ??



> The ramdisk block driver is crusty and probably
> qualifies as broken
> on 32-bit due to the resource scalability issues. It
> would be much
> easier (and you'd encounter much less negative
> feedback) using ramfs or
> a 64-bit architecture.
> 

Ok, I will try that through ramfs. but using 64bit
machine is not feasible for me. 


Thanks

Fawad Lateef


	
		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - You care about security. So do we. 
http://promotions.yahoo.com/new_mail
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
