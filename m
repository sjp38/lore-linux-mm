Date: Sun, 29 Jul 2001 21:44:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <Pine.LNX.4.33L.0107291724290.11893-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.21.0107292131380.1085-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Daniel Phillips <phillips@bonn-fries.net>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Rik van Riel wrote:
> 
> Actually, I liked the fact that we could change the policy
> of up and down aging of pages in one place instead of having
> to edit the source in multiple places...

No question, that was a good principle; but in practice there were or
are very few places where they were used, yet far too many variants
provided, some with awkward side-effects on the lists.

I've no objection to one age_page_up() and one age_page_down()
(though I do find the term "age" unhelpful here), inline or macro,
but even so a lot seems to depend on where and when we initialize it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
