Date: Fri, 27 Apr 2001 11:26:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] bgaging + balance  v2
In-Reply-To: <Pine.LNX.4.21.0104270317090.2587-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0104271125460.19012-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Apr 2001, Marcelo Tosatti wrote:
> On Thu, 26 Apr 2001, Rik van Riel wrote:
> 
> > in my patch yesterday evening there was a big mistake;
> > the old line calculating maxscan wasn't removed, so all
> > the fancy recalculation wouldn't do anything ;)
> 
> How about this patch on top of yours? ;)

Simply turn it into:

	count = refill_inactive_scan(DEF_PRIORITY, count);

that will achieve the same.  And yes, it was a thinko
by me ...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
