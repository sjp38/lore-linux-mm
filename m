Date: Sun, 4 Aug 2002 16:54:38 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: how not to write a search algorithm
In-Reply-To: <3D4D87CE.25198C28@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0208041654140.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Aug 2002, Andrew Morton wrote:
> Rik van Riel wrote:
> >
> > ...
> > > Alan's kernel has a nice-looking implementation.  I'll lift that out
> > > next week unless someone beats me to it.
> >
> > Good to hear that you found this one ;)
>
> The same test panics Alan's kernel with pte_chain oom, so I can't
> check whether/how well it fixes it :(

> Is there a proposed way of recovering from pte_chain oom?

I think wli is working on a patch for this.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
