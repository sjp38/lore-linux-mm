Date: Sat, 20 Jul 2002 11:22:51 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH 6/6] Updated VM statistics patch
In-Reply-To: <Pine.LNX.4.44.0207200645360.6298-100000@loke.as.arizona.edu>
Message-ID: <Pine.LNX.4.44L.0207201122220.12241-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 20 Jul 2002, Craig Kulesa wrote:
> On Sat, 20 Jul 2002, Rik van Riel wrote:
>
> > Except for the fact that you'll count every new page allocation
> > as an activation, which isn't quite the intended behaviour ;)
>
> *thwaps forehead*   Ohhh, quite right.  Darn.  :)
>
> Hmmm.  Does it sound acceptable to still increment pgdeactivate in
> mm_inline.h, and explicitly put hooks for pgactivate in the select
> places where pages really _are_ being 'reactivated'?

Acceptable, sure ... but probably not worth it as Linus merged
the VM statistics into his tree yesterday afternoon.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
