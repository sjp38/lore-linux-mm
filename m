Date: Mon, 26 Aug 2002 21:13:38 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: MM patches against 2.5.31
In-Reply-To: <3D6AC0BB.FE65D5F7@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0208262113070.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>, Daniel Phillips <phillips@arcor.de>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Aug 2002, Andrew Morton wrote:

> Well we wouldn't want to leave tons of free pages on the LRU - the VM
> would needlessly reclaim pagecache before finding the free pages.  And
> higher-order page allocations could suffer.

We did this with the swap cache in 2.4.<7 and it was an
absolute disaster.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
