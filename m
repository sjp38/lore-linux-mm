Date: Fri, 13 Dec 2002 00:08:03 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: rmap15a swappy?
In-Reply-To: <6uisxzrl00.fsf@zork.zork.net>
Message-ID: <Pine.LNX.4.50L.0212130007070.17748-100000@imladris.surriel.com>
References: <6uu1hjruye.fsf@zork.zork.net> <Pine.LNX.4.50L.0212121913030.17748-100000@imladris.surriel.com>
 <6uisxzrl00.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sean Neakums <sneakums@zork.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Dec 2002, Sean Neakums wrote:
> > On Thu, 12 Dec 2002, Sean Neakums wrote:
> >
> > Indeed, the older rmaps swapped later.  However, swapping
> > a little bit earlier turns out to be faster for almost all
> > workloads.
>
> Oh right, because if you get sudden memory pressure you have a bunch
> of pages that you can just throw away without writeout?

Exactly.

> Anyway, that's nifty.  I just wanted to make sure it wasn't a
> regression.

I know there are a few regressions in "strange" corner cases,
stuff I can easily reproduce with special test programs but
haven't seen in real life. I'm still ironing out those.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
