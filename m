Date: Sun, 15 Sep 2002 11:58:27 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.34-mm2
In-Reply-To: <3D841C8A.682E6A5C@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209151156080.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Daniel Phillips <phillips@arcor.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Sep 2002, Andrew Morton wrote:
> Daniel Phillips wrote:

> > but that sure looks like the low hanging fruit.
>
> It's low alright.  AFAIK Linux has always had this problem of
> seizing up when there's a lot of dirty data around.

Somehow I doubt the "seizing up" problem is caused by too much
scanning.  In fact, I'm pretty convinced it is caused by having
too much IO submitted at once (and stalling in __get_request_wait).

The scanning is probably not relevant at all and it may be
beneficial to just ignore the scanning for now and do our best
to keep the pages in better LRU order.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
