Date: Thu, 23 May 2002 06:36:54 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: noninterfering drop_page()
In-Reply-To: <20020522051102.GN2046@holomorphy.com>
Message-ID: <Pine.LNX.4.44L.0205230633470.23276-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 May 2002, William Lee Irwin III wrote:

> Brewed this up a while ago as part of the rmap_locking project, though
> the forward port itself hasn't gone through much more than a test boot.

> # 02/05/21	wli@tisifone.holomorphy.com	1.424
> # Noninterfering drop_page(). Doesn't grab at the global lock, but rather sets a per-page flag
> # signalling to VM scanning that the page should be aggressively reclaimed.

This means we would reclaim normal inactive pages before
looking at the "dropped" pages that still linger on the
active list.

I'm not sure what this patch achieves except for disabling
drop-behind (you'll end up reclaiming non-mapped pagecache
pages in something resembling FIFO order).

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
