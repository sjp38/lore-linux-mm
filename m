Date: Thu, 23 May 2002 08:43:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: noninterfering drop_page()
Message-ID: <20020523154320.GF14918@holomorphy.com>
References: <20020522051102.GN2046@holomorphy.com> <Pine.LNX.4.44L.0205230633470.23276-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0205230633470.23276-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 May 2002, William Lee Irwin III wrote:
>> Brewed this up a while ago as part of the rmap_locking project, though
>> the forward port itself hasn't gone through much more than a test boot.
>> # 02/05/21	wli@tisifone.holomorphy.com	1.424
>> # Noninterfering drop_page(). Doesn't grab at the global lock, but rather sets a per-page flag
>> # signalling to VM scanning that the page should be aggressively reclaimed.

On Thu, May 23, 2002 at 06:36:54AM -0300, Rik van Riel wrote:
> This means we would reclaim normal inactive pages before
> looking at the "dropped" pages that still linger on the
> active list.
> I'm not sure what this patch achieves except for disabling
> drop-behind (you'll end up reclaiming non-mapped pagecache
> pages in something resembling FIFO order).

Okay, I didn't want to do semantic damage but it happened anyway.
There seems to be some kind of unexpected (by me) dependency on list
ordering. There are other ways to mitigate the grabbing at the global
lock (which I've in fact already implemented), although none quite so
effective as the per-page business. Which doesn't mean much as a lock
grab is not going to cost anywhere near as much as inaccurate page
replacement, so drop this one.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
