Date: Wed, 25 Aug 2004 13:54:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Documentation/vm/balance really outdated
Message-ID: <20040825205457.GJ2793@holomorphy.com>
References: <20040825184520.GA23878@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040825184520.GA23878@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2004 at 03:45:20PM -0300, Marcelo Tosatti wrote:
> The file Documentation/vm/balance was written by Kanoj in 2000, and
> is completly outdated to what we have now.
> Last paragraph:
> pages_min/pages_low/pages_high/low_on_memory/zone_wake_kswapd: These are
> per-zone fields, used to determine when a zone needs to be balanced. When
> the number of pages falls below pages_min, the hysteric field low_on_memory
> gets set. This stays set till the number of free pages becomes pages_high.
> When low_on_memory is set, page allocation requests will try to free some
> pages in the zone (providing GFP_WAIT is set in the request). Orthogonal
> to this, is the decision to poke kswapd to free some zone pages. That
> decision is not hysteresis based, and is done when the number of free
> pages is below pages_low; in which case zone_wake_kswapd is also set.
> Should we just remove it? 

pages_min, pages_low, and pages_high are still in use, but with more
precisely-defined semantics. low_on_memory is gone, and min_free_kb,
overcommit_memory, and swappiness have arrived for different purposes.
I find the value of this documentation rather unclear particularly given
that it's not been examined in so long. Maybe kerneldoc is the way.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
