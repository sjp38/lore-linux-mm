Date: Mon, 22 Jul 2002 10:44:49 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH][1/2] return values shrink_dcache_memory etc
In-Reply-To: <Pine.LNX.4.44L.0207221029590.3086-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.44L.0207221043050.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2002, Rik van Riel wrote:

> Apart from both of these we'll also need code to garbage collect
> empty page tables so users can't clog up memory by mmaping a page
> every 4 MB ;)

Btw, I've started work on this code already.

Putting the dcache/icache pages on the LRU list in the way
Linus wanted is definately a lower priority thing for me at
this point, especially considering the fact that Ed Tomlinson's
way of having these pages on the LRU seems to work just fine ;)

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
