Date: Tue, 3 Apr 2001 18:35:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Fwd: Re: [PATCH][RFC] appling preasure to icache and dcache
In-Reply-To: <01040317251303.31476@oscar>
Message-ID: <Pine.LNX.4.21.0104031832540.14090-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org, squash@primary.net
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2001, Ed Tomlinson wrote:
> On Tuesday 03 April 2001 11:03, Benjamin Redelings I wrote:
> > Hi, I'm glad somebody is working on this!  VM-time seems like a pretty
> > useful concept.
> 
> Think it might be useful for detecting trashing too.  If vmtime is
> made to directly relate to the page allocation rate then you can do
> something like this.  Let K be a number intially representing 25% of
> ram pages. Because vmtime is directly releated to allocation rates its
> meanful to subtract K from the current vmtime.  For each swapped out
> page, record the current vmtime.  Now if the recorded vmtime of the
> page you are swapping in is greater than vmtime-K increment A
> otherwise increment B. If A>B we are thrashing.  We decay A and B via
> kswapd.  We adjust K depending on the swapping rate.  Thoughts?

Hmmm, how exactly would this algorithm work ?

>From your description above, I can't quite see how it would
work (or why it would work).

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
