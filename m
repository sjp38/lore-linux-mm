Date: Thu, 18 Jan 2001 11:55:23 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Yet another bogus piece of do_try_to_free_pages()
In-Reply-To: <Pine.LNX.4.30.0101172021270.7218-100000@elte.hu>
Message-ID: <Pine.LNX.4.31.0101181154010.31432-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Zlatko Calusic <zlatko@iskon.hr>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jan 2001, Ingo Molnar wrote:
> On 17 Jan 2001, Zlatko Calusic wrote:
>
> > Oh, believe me I tested that patch very thoroughly with lots of
> > utilities, and it worked very very well. I don't remember that it
> > fiddled anywhere with the PG_MEMALLOC flag.
>
> yep, same result here, Marcelo's patch is plain *wonderful*.
> Combined with the block-IO changes, -pre8 is really behaving
> spectacularly in under high VM or pagecache load.

Oh, I'm not doubting that. I just got suspicious when Linus
got asked to put it in the kernel after Zlatko tested it for
a few hours ... and when I spotted a lack of flags|=PF_MEMALLOC
around the thing.

(but from what marcelo told me, it got fixed in -pre8)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
