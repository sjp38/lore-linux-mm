Date: Sat, 8 Apr 2000 02:04:06 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004072012.NAA10407@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004080154030.2121-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Kanoj Sarcar wrote:

>are unneeded when you consider the kernel_lock is already held in most
>of those paths.[..]

Good point. However I'm not thinking and I'm not going to think with the
big kernel lock in mind in the paths where we incidentally hold the big
kernel lock because somebody _else_ still needs it (like with
acquire_swap_page/get_swap_page/swap_free). The setting of SWP_USED in
swapoff have to be done inside the critical section protected by the
swaplist lock. That was at least a conceptual bug even if it couldn't
trigger due swap_out and swapoff that both holds the big kernel lock.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
