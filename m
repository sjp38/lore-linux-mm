Date: Sat, 8 Apr 2000 15:30:47 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004080011.RAA21305@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004081520410.559-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Kanoj Sarcar wrote:

>Be aware that I already have a patch for this. I have been meaning to 

I've a patch for this too now. Are you using read_swap_cache from any
swapin event? The problem is swapin can't use read_swap_cache because with
read_swap_cache we would never know if we're doing I/O on an inactive swap
entry. Only swapoff can use read_swap_cache. My current tree is doing this
and it's using the swap cache as locking entity to serialize with
unuse_process plus checks on the pte with the page cache lock acquired to
know if lookup_swap_cache (or the swap cache miss path) returned a swap
cache or not (if not then we have to giveup without changing the pte since
swapoff just solved the page fault from under us).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
