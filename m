Date: Mon, 19 Jun 2000 14:51:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] -ac21 don't set referenced bit
In-Reply-To: <Pine.LNX.4.21.0006191907240.6888-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006191450100.13200-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, los@lsdb.bwl.uni-mannheim.de
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, Andrea Arcangeli wrote:
> On Mon, 19 Jun 2000, Rik van Riel wrote:
> 
> >#define lru_cache_add(page)                     \
> >do {                                            \
> >        spin_lock(&pagemap_lru_lock);           \
> >        list_add(&(page)->lru, &lru_cache);     \
> >        nr_lru_pages++;                         \
> >        page->age = PG_AGE_START;               \
> >        ClearPageReferenced(page);              \
> >        SetPageActive(page);                    \
> >        spin_unlock(&pagemap_lru_lock);         \
> >} while (0)
> >
> >We've had this for a number of kernel versions now...
> 
> Woops, sorry I missed that (I rewrote all such functions and I
> had in mind the old ones). However clearing there cause some
> place to clear two times.

My approach is a bit simpler. Since we *always* want to clear
the bit when we put the page in the LRU list, we can simply
remove that piece of code duplication from elsewhere in the
code.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
