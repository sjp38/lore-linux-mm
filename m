Date: Sat, 4 Aug 2001 04:13:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.21.0108040222561.9719-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0108040411220.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 4 Aug 2001, Marcelo Tosatti wrote:

> Well, the freepages_high change needs more work.
>
> Normal allocations are not going to easily "fall down" to lower zones
> because the high zones will be kept at freepages.high most of the time.

Actually, the first allocation loop in __alloc_pages()
is testing against zone->pages_high and allocating only
from zones which have MORE than this.

So I guess this should only result in a somewhat slower
and/or softer fallback and definately worth a try.

Oh, and we definately need to un-lazy the queue movement
from the inactive_clean list. Having all of the pages you
counted on as being reclaimable referenced is a very bad
surprise ...

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
