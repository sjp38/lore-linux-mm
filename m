Date: Sat, 20 Jul 2002 18:42:03 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH][1/2] return values shrink_dcache_memory etc
In-Reply-To: <Pine.LNX.4.44.0207201351160.1552-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.44L.0207201838430.12241-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Jul 2002, Linus Torvalds wrote:
> On Sat, 20 Jul 2002, Rik van Riel wrote:
> >
> > OK, I'll try to forward-port Ed's code to do that from 2.4 to 2.5
> > this weekend...
>
> Side note: while I absolutely think that is the right thing to do, that's
> also the much more "interesting" change. As a result, I'd be happier if it
> went through channels (ie probably Andrew) and had some wider testing
> first at least in the form of a CFT on linux-kernel.

Absolutely. This idea has been implemented but hasn't yet
received wider testing.

I guess I'll try to get this patch on LWN with a large
CFT attached ;)))

> [ Or has it already been in 2.4.x in any major tree?

Not yet. I'll pass it on through Andrew...

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
