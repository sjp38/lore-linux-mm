From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004082147.OAA75650@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Sat, 8 Apr 2000 14:47:29 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004080305490.2459-100000@alpha.random> from "Andrea Arcangeli" at Apr 08, 2000 03:14:40 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Fri, 7 Apr 2000, Kanoj Sarcar wrote:
> 
> >> BTW, swap_out() always used the same locking order that I added to swapoff
> >> so if my patch is wrong, swap_out() is always been wrong as well ;).
> >
> >Not sure what you mean ... swap_out never grabbed the mmap_sem/page_table_lock
> >before (in 2.2. too).
> 
> In 2.2.x page_table_lock wasn't necessary because we was holding the big
> kernel lock.

You have answered your own question in a later email. I quote you:
"Are you using read_swap_cache from any
swapin event? The problem is swapin can't use read_swap_cache because with
read_swap_cache we would never know if we're doing I/O on an inactive swap
entry"

Grabbing lock_kernel in swap_in is not enough since it might get dropped
if the swap_in code goes to sleep for some reason.

Kanoj

> 
> In 2.3.x vmlist_*_lock is alias to spin_lock(&mm->page_table_lock) and
> swap_out isn't even calling the spin_lock explicitly but it's doing what
> the fixed swapoff does.
> 
> Andrea
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
