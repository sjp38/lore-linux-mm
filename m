Date: Sat, 16 Sep 2000 15:22:36 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Happiness with t8-vmpatch4 (was Re:  Does page-aging really
 work?)
In-Reply-To: <39C3BA07.9525723F@ucla.edu>
Message-ID: <Pine.LNX.4.21.0009161521020.1519-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2000, Benjamin Redelings I wrote:

> > This is indeed something to look at. Maybe we could give
> > idle processes (sleeping for more than 20 seconds?) a
> > "full" swap_cnt instead of swap_cnt = rss >> SWAP_SHIFT ?
>
>  This doesn't seem like it should be necessary.  Right now,
> unused processes ARE swapped preferentially (and completely) -
> its just that swapping happens all of a sudden.

We may be able to fix that by swapping long-idle processes
before we have eaten all of the cache. 

> 	Evicting unused pages, either from the cache or from
> process can have significant benefits on my machine (64Mb).  
> Once swapping triggered, 20Mb were paged out, and stayed out.  
> If these 20 Mb had been paged out before, then I would have had
> 20Mb more cache to work with, which is 31% of my memory.  Go
> figure :)

*nod*

> BTW, with test8-vmpatch4, I am gettings zillions of "VM:
> page_launder, found pre-cleaned page ?!" messages.

No you're not. That's test8-vmpatch3.
This is fixed in -vmpatch4...

(and the comments in the code have been
updated to explain how and what)

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
