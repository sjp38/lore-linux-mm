Date: Wed, 15 Aug 2001 19:00:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0108151854300.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Linus Torvalds wrote:

> Btw, the whole comment around the fs/buffer.c braindamage is telling:
>
>         /* We're _really_ low on memory. Now we just
>          * wait for old buffer heads to become free due to
>          * finishing IO.  Since this is an async request and
>          * the reserve list is empty, we're sure there are
>          * async buffer heads in use.
>          */
>         run_task_queue(&tq_disk);
>
>         current->policy |= SCHED_YIELD;
>         __set_current_state(TASK_RUNNING);
>         schedule();
>         goto try_again;
>
> It used to be correct, say about a few years ago.

IIRC this code was introduced less than two months ago
due to a race condition in the old code, where the
allocator just went to sleep waiting for things to
improve. ;)

It's good to see you've reversed your position that
there would be nothing we could do in this situation.

The patch looks good at first sight, lets hope there
are no hidden locking issues in obscure situations...

regards,

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
