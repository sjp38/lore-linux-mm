Date: Fri, 29 Sep 2000 11:34:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: lru_cache_add() -> deactivate_page_nolock()?
In-Reply-To: <39D3F272.BC026A47@sgi.com>
Message-ID: <Pine.LNX.4.21.0009291133190.23266-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@conectiva.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Rajagopal Ananthanarayanan wrote:

> Two cases here, depending on what happened in __alloc_pages():
> 
> 1. page->age will be PAGE_AGE_START if page was previously
>    freed (__free_pages_ok() sets the age)
> 
> 2. page->age will be zero if page was obtained through
>    a reclaim_page().
> 
> I can't believe this was a design choice. Simply
> code like this is missing at the bottom of reclaim_page():
> 
> ---------
> struct page * reclaim_page(zone_t * zone)
> {
> 	[ ... ]
> 	if (page)
> 		page->age = PAGE_START_AGE;
> 	return page;
> }
> ----------
> 
> This will avoid nasty deactivation immediately on
> entering the page into the cache.
> 
> ... btw, I have tried the above fix, and it does
> improve dbench performance in cases where few
> clients (1-2) are used on my 64MB system.
> 
> Rik, what do you think?

You're absolutely right. 

This is a bug which should be fixed.

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
