Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Sun, 29 Jul 2001 23:20:21 +0200
References: <Pine.LNX.4.21.0107292131380.1085-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.21.0107292131380.1085-100000@localhost.localdomain>
MIME-Version: 1.0
Message-Id: <01072923202100.01194@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sunday 29 July 2001 22:44, Hugh Dickins wrote:
> On Sun, 29 Jul 2001, Rik van Riel wrote:
> > Actually, I liked the fact that we could change the policy
> > of up and down aging of pages in one place instead of having
> > to edit the source in multiple places...
>
> No question, that was a good principle; but in practice there were or
> are very few places where they were used, yet far too many variants
> provided, some with awkward side-effects on the lists.
>
> I've no objection to one age_page_up() and one age_page_down()
> (though I do find the term "age" unhelpful here), inline or macro,
> but even so a lot seems to depend on where and when we initialize it.

"Age" is hugely misleading, I think everybody agrees, but we are still 
in a stable series, and a global name change would just make it harder 
to apply patches.

That said, I think BSD uses "weight".  It's not a lot better, but at 
least you know that the more heaviliy weighted page is one with the 
higher weight value, whereas we have "age up" meaning "make younger" :-/

And how can age go up and down anyway?  I'd prefer to talk about 
->temperature, more in line with what we see in the literature.

But then, it's so easy to talk about "aging", what would it be with 
->temperature:  Heating?  Cooling?  Stirring?  ;-)

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
