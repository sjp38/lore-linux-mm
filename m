Date: Sun, 29 Jul 2001 17:25:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <Pine.LNX.4.21.0107292116530.1014-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33L.0107291724290.11893-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Daniel Phillips <phillips@bonn-fries.net>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Hugh Dickins wrote:
> On Sun, 29 Jul 2001, Linus Torvalds wrote:
> >
> > Removed. Which makes all the "age_page_up*()" functions go away entirely.
> > They were mostly gone already.
>
> Applause!  And for your encore... see how many age_page_down*()s
> there are (3), and how many uses (1).  Same fate, please!

Actually, I liked the fact that we could change the policy
of up and down aging of pages in one place instead of having
to edit the source in multiple places...

But yes, for this macros would be better than functions ;)

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
see: http://www.linux-mm.org/
