Date: Sat, 16 Sep 2000 04:57:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Happiness with t8-vmpatch4 (was Re:  Does page-aging really
 work?)
In-Reply-To: <39C31C9F.1C202CD8@ucla.edu>
Message-ID: <Pine.LNX.4.21.0009160455260.1519-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2000, Benjamin Redelings I wrote:

>    1. test8-vmpatch4 does not swap very much at first, but then
> swaps a lot of memory in a short time when triggered.

>   2. I guess we could wish that unused programs got swapped a
> bit sooner instead of all at once - but presumably that can be
> tuned.

This is indeed something to look at. Maybe we could give
idle processes (sleeping for more than 20 seconds?) a
"full" swap_cnt instead of swap_cnt = rss >> SWAP_SHIFT ?

And we could also start swapping a bit earlier when the
cache is getting small, but I'm not sure about how to
do this or exactly what performance benefits that would
give ...

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
