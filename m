From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004082321.QAA01209@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Sat, 8 Apr 2000 16:21:17 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004090102560.342-100000@alpha.random> from "Andrea Arcangeli" at Apr 09, 2000 01:10:19 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> I was talking about the locking order issue you raised about the necessary
> vmlist_*_lock I added in swapoff.
> 
> What I meant is that in 2.2.x there was no need of the
> vmlist_*_lock/page_cache_lock in swapoff because we was relying on the big
> kernel lock while playing with pagetables and vmas (same in swap_out()).
> 
> In 2.3.x both swap_out and swapoff needs to grab first the tasklist_lock
> (as in 2.2.x) and then the vmlist_*_lock (otherwise as first the vma
> browsing may happen during a vma list modification).
> 
> Andrea
> 


As I mentioned before, have you stress tested this to make sure grabbing
read_lock(tasklist_lock), then spin_lock(vmlist_lock) is not deadlock
prone? I _think_ you will run into problems ... and we can then stop 
discussing this. 

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
