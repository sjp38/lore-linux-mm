Date: Mon, 19 Jun 2000 19:10:11 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] -ac21 don't set referenced bit
In-Reply-To: <Pine.LNX.4.21.0006191359160.13200-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006191907240.6888-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, los@lsdb.bwl.uni-mannheim.de
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, Rik van Riel wrote:

>#define lru_cache_add(page)                     \
>do {                                            \
>        spin_lock(&pagemap_lru_lock);           \
>        list_add(&(page)->lru, &lru_cache);     \
>        nr_lru_pages++;                         \
>        page->age = PG_AGE_START;               \
>        ClearPageReferenced(page);              \
>        SetPageActive(page);                    \
>        spin_unlock(&pagemap_lru_lock);         \
>} while (0)
>
>We've had this for a number of kernel versions now...

Woops, sorry I missed that (I rewrote all such functions and I had in mind
the old ones). However clearing there cause some place to clear two
times. Just think what we do when we insert a page in the page
cache. That's why I'm not embedding the reference bit clear into the
lru_cache_add.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
