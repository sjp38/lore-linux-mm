Date: Thu, 16 Aug 2001 23:09:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: help for swap encryption
In-Reply-To: <Pine.GSO.4.31.0108161312050.29454-100000@cardinal0.Stanford.EDU>
Message-ID: <Pine.LNX.4.33L.0108162307290.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ted Unangst <tedu@Stanford.EDU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2001, Ted Unangst wrote:

> 1.  the data is at page->virtual, right?  that's what i want.

Doing this will make your scheme unable to work on
machines with more than 890MB of RAM.

> 2.  if a page gets written to disk, nobody will be trying to read the
> former RAM location, correct?  i was going to encrypt the ram in place.
> nobody is going to go back and try reading that RAM again, are they?

Wrong. You'll have to remove the page from the swap
cache first, possibly moving it to an encrypted
swap cache ;)

> 3.  when a page is pulled off disk, it's not automatically deleted.
> when does that occur?

It only occurs when swap space is getting full and
is done in do_swap_page().

> 4.  i don't know much about kernel programming style.  would it be
> better to store tables of data as static variables, or kmalloc a big
> chunk at some point?

Using static variables you'd make your algorithm
unable to run on multiple CPUs at the same time on
an SMP system and is cause for instant disqualification.

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
