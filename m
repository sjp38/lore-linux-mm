Date: Sat, 20 Jul 2002 07:15:08 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: Re: [PATCH 6/6] Updated VM statistics patch
In-Reply-To: <Pine.LNX.4.44L.0207201006100.12241-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.44.0207200645360.6298-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 20 Jul 2002, Rik van Riel wrote:

> Except for the fact that you'll count every new page allocation
> as an activation, which isn't quite the intended behaviour ;)

*thwaps forehead*   Ohhh, quite right.  Darn.  :) 

Hmmm.  Does it sound acceptable to still increment pgdeactivate in
mm_inline.h, and explicitly put hooks for pgactivate in the select places
where pages really _are_ being 'reactivated'?  That sounds fairly sensible
to me -- unless you want to differentiate between pages that leave the
active list via drop_behind() versus deactivate_page_nolock().

Many thanks,
-Craig

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
