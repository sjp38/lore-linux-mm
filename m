Date: Fri, 16 Aug 2002 21:32:06 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: clean up mem_map usage ... part 1
In-Reply-To: <3D5D7572.DD7ACA23@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0208162131200.1430-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Aug 2002, Andrew Morton wrote:

> Oh whatever.  If it's in my pile then a few more people get to
> bang on it for a while.  Looks like a long backlog will become
> a permanent state, so I'll need to do something more organised
> there.

Another reason why I decided to do the page_launder/shrink_cache
rewrite on 2.4 first.  Once it's stable and the corner cases have
been ironed out I'll give you something that just works. ;)

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
