Date: Sat, 8 Apr 2000 15:14:40 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004080015.RAA04351@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004080305490.2459-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Kanoj Sarcar wrote:

>> BTW, swap_out() always used the same locking order that I added to swapoff
>> so if my patch is wrong, swap_out() is always been wrong as well ;).
>
>Not sure what you mean ... swap_out never grabbed the mmap_sem/page_table_lock
>before (in 2.2. too).

In 2.2.x page_table_lock wasn't necessary because we was holding the big
kernel lock.

In 2.3.x vmlist_*_lock is alias to spin_lock(&mm->page_table_lock) and
swap_out isn't even calling the spin_lock explicitly but it's doing what
the fixed swapoff does.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
