Date: Sat, 22 Apr 2000 03:12:19 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004211735510.11459-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004220306410.584-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Apr 2000, Rik van Riel wrote:

>you could use the PageClearSwapCache and related macros for
>changing the bitflags.

BTW, thinking more I think the clearbit in shrink_mmap should really be
atomic (lookup_swap_cache can run from under it and try to lock the page
playing with the page->flags while we're clearing the swap_entry bitflag).

The other places doesn't need to be atomic as far I can tell so (as just
said) I'd prefer not to add unscalable SMP locking. Suggest a name for a
new macro that doesn't use asm and I can use it of course.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
