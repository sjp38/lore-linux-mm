Date: Mon, 29 Jan 2001 19:22:29 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux-2.4.1-pre11
In-Reply-To: <Pine.LNX.4.21.0101291548400.14756-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101291816100.1321-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2001, Marcelo Tosatti wrote:

> Btw, look at this part of code from kswapd: 
> 
>                  * 1) we need no more free pages   or
>                  * 2) the inactive pages need to be flushed to disk,
>                  *    it wouldn't help to eat CPU time now ...

>                 if (!free_shortage() || !inactive_shortage()) {
>                         interruptible_sleep_on_timeout(&kswapd_wait, HZ);
> 
> kswapd goes to sleep if there is no free shortage, even if the
> inactive list is under shortage.
> 
> Why not refill the inactive list when the inactive list is under
> shortage? :)

At this point, we already scanned the active list and we
know we're not getting any more aging information at this
point.

In this case, it might be better to leave the active pages
alone for a while and give userland a chance to use the
pages so we can get some aging information the next time we
scan the list.

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
