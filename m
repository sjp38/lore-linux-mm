Date: Mon, 16 Jul 2001 16:04:14 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
In-Reply-To: <20010716165655.D28023@redhat.com>
Message-ID: <Pine.LNX.4.33L.0107161600460.5738-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Bulent Abali <abali@us.ibm.com>, Mike Galbraith <mikeg@wen-online.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jul 2001, Stephen C. Tweedie wrote:

> On a 20MB box with 16MB DMA zone and 4MB NORMAL zone, a low rate of
> allocations will be continually satisfied from the NORMAL zone
> resulting in constant aging and pageout within that zone, but with no
> pressure at all on the larger 16MB DMA zone.  That's hardly fair.

It shouldn't. Pages in both zones get aged equally,
leading to both zones getting above the various
allocation watermarks in turn and getting pages
allocated from them in turn.

If what you are describing is happening, we have a
bug in the implementation of the current scheme.

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
