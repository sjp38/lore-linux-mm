Date: Sat, 8 Apr 2000 01:54:02 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004072012.NAA10407@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004080142340.2121-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Kanoj Sarcar wrote:

>[..] A bigger problem might
>be that you are violating lock orders when you grab the vmlist_lock
>from inside code that already has tasklist_lock in readmode [..]

Conceptually it's the obviously right locking order. The mm exists in
function of a task struct. So first grabbing the tasklist lock, finding
the task_struct and then locking its mm before playing with it looks the
natural ordering of things and how things should be done.

BTW, swap_out() always used the same locking order that I added to swapoff
so if my patch is wrong, swap_out() is always been wrong as well ;).

I had a fast look and it seems nobody is going to harm swap_out and
swapoff but if somebody is using the inverse lock I'd much prefer to fix
that path because the locking design of swapoff and swap_out looks the
obviously right one to me.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
