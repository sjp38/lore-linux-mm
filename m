Date: Fri, 22 Sep 2000 05:49:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.0-test9-pre4: __alloc_pages(...) try_again:
In-Reply-To: <Pine.Linu.4.10.10009220754250.1064-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0009220544590.27435-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: Roger Larsson <roger.larsson@norran.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2000, Mike Galbraith wrote:

> Much more interesting (i hope) is that refill_inactive() _is_
> present 2923 times, we're oom as heck, and neither shm_swap()
> nor swap_out() is ever reached in 1048533 lines of trace.  The
> only way I can see that this can happen is if
> refill_inactive_scan() eats all count.

> :-) I'm currently wo^Handering what count is and if I shouldn't try
> checking nr_inactive_clean_pages() before exiting the loop.

This means that refill_inactive_scan() has moved
so many pages to the inactive_dirty/clean list we
have satisfied both the inactive_target and the
free_target ...

Maybe, however, these pages are not freeable and
page_launder() moves them back to the active list
and we end up moving pages from one list to another ????

With the latest change to get all pages properly
deactivated when needed, maybe this is possible to
happen. It /seems/ possible now that I think about
it, very very unlikely, but possible ;(

Btw, was there any swap free when you got into
this situation ?

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
