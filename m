Date: Wed, 17 Jan 2001 18:19:31 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: swapout selection change in pre1
In-Reply-To: <01011420222701.14309@oscar>
Message-ID: <Pine.LNX.4.31.0101171817180.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 Jan 2001, Ed Tomlinson wrote:

> Think its gone too far in the other direction now.  Running a
> heavily threaded java program, 35 threads and RSS of 44M a 128M
> KIII-400 with cpu usage of 4-10%, the rest of the system is
> getting paged out very quickly and X feels slugish.  While we
> may not want to treat each thread as if it was a process, I
> think we need more than one scan per group of threads sharing
> memory.
>
> Ideas?

Bullshit.

The old MM selection code used mm->swap_cnt to give
exactly the same result, only scanning through a larger
list.

The change that could affect this could be the thing
where we immediately unmap a page from a process if it
isn't used, so refill_inactive_scan() has better chances.

I have something (ugly?) for this in my patch on
http://www.surriel.com/patches/ ... I'll clean it up and
send it.

(damn, a week without internet is horrible ... lots of
duplicated/different/... work, some of it wasted)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
