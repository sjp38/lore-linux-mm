Date: Thu, 4 May 2000 15:30:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH][RFC] Alternate shrink_mmap
In-Reply-To: <39119655.D6E97EF6@norran.net>
Message-ID: <Pine.LNX.4.21.0005041524220.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Roger Larsson wrote:

> I have noticed (not by running - lucky me) that I break this
> assumption....
> /*
>  * NOTE: to avoid deadlocking you must never acquire the pagecache_lock
> with
>  *       the pagemap_lru_lock held.
>  */

Also, you seem to start scanning at the beginning of the
list every time, instead of moving the list head around
so you scan all pages in the list evenly...

Anyway, I'll use something like your code, but have two
lists (an active and an inactive list, like the BSD's
seem to have).

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
