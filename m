Date: Thu, 12 Dec 2002 19:14:15 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: rmap15a swappy?
In-Reply-To: <6uu1hjruye.fsf@zork.zork.net>
Message-ID: <Pine.LNX.4.50L.0212121913030.17748-100000@imladris.surriel.com>
References: <6uu1hjruye.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sean Neakums <sneakums@zork.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Dec 2002, Sean Neakums wrote:

> I just fitted an extra 512M of RAM to my laptop, and though there is
> currently about 400M free, it is still hitting swap.  I seem to recall
> that older rmaps generally only started to page stuff out when there
> was no more memory free.  (My recollection may be faulty, though.)

Indeed, the older rmaps swapped later.  However, swapping
a little bit earlier turns out to be faster for almost all
workloads.

Having said that, for some reason rmap15a is sometimes
swapping a lot too early. This is something I still have
to fix...

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
