Message-ID: <20041209125425.85749.qmail@web53901.mail.yahoo.com>
Date: Thu, 9 Dec 2004 04:54:25 -0800 (PST)
From: Fawad Lateef <fawad_lateef@yahoo.com>
Subject: Fwd: Re: Plzz help me regarding HIGHMEM (PAE) confusion in Linux-2.4 ???
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- William Lee Irwin III <wli@holomorphy.com> wrote:

> Only %cr3 is restricted to 32-bit physical
> addresses. The entries in
> the pgd's, pmd's, and pte's themselves are all
> 36-bit physical
> addresses.
> 

but what I saw is that the pgd is loaded in cr3 when
the switch_mm takes place in the scheduling of
process. And PGD is of 64bit size ................ can
u please explain this ???

Actually I m concerned in accessing 4GB to 32GB for
ramdisk, and when I used to access those through
kmap_atomic in a single module system crashes after
passing the first 4GB of RAM (screen shows garbage and
then system crashes), I got to know that a process can
only access 4GB, so I created kernel threads for each
4GB and allocated struct mm_struct entry to that
through mm_alloc function and then assigned that to
the task_struct->active_mm to each thread, (in thread
before mm_alloc I called daemonize too)......... 

Now I think that all threads are now different
processes, but the system crashing behaviour is the
same ............. kernel is 2.4.25 

Can u plz suggest me some way of doing this ???


Thanks 

Fawad Lateef


		
__________________________________ 
Do you Yahoo!? 
All your favorites on one personal page ? Try My Yahoo!
http://my.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
