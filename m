Date: Sun, 29 Jul 2001 22:51:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <01072923202100.01194@starship>
Message-ID: <Pine.LNX.4.21.0107292242170.1279-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, "Linus Torvalds <torvalds@transmeta.com> Marcelo Tosatti" <marcelo@conectiva.com.br>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Daniel Phillips wrote:
> 
> "Age" is hugely misleading, I think everybody agrees, but we are still 
> in a stable series, and a global name change would just make it harder 
> to apply patches.

There are very few places where "age" comes in.  Not my call,
but I doubt we're so frozen as to have to stick with that name.

> That said, I think BSD uses "weight".  It's not a lot better, but at 
> least you know that the more heaviliy weighted page is one with the 
> higher weight value, whereas we have "age up" meaning "make younger" :-/
> 
> And how can age go up and down anyway?  I'd prefer to talk about 
> ->temperature, more in line with what we see in the literature.
> 
> But then, it's so easy to talk about "aging", what would it be with 
> ->temperature:  Heating?  Cooling?  Stirring?  ;-)

That's much _much_ better: I'd go for "warmth" myself, warm_page_up()
and cool_page_down().  I particularly like the ambiguity, that a warmer
page may be a more recently used page or a more frequently used page.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
