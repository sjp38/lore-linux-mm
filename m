Date: Mon, 8 Aug 2005 16:30:17 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: Re: [RFC 1/3] non-resident page tracking
In-Reply-To: <20050808.132603.93023622.davem@davemloft.net>
Message-ID: <Pine.LNX.4.61L.0508081628580.15038@imladris.surriel.com>
References: <20050808201416.450491000@jumble.boston.redhat.com>
 <20050808202110.744344000@jumble.boston.redhat.com>
 <20050808.132603.93023622.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Aug 2005, David S. Miller wrote:

> > @@ -359,7 +362,10 @@ struct page *read_swap_cache_async(swp_e

> > -			lru_cache_add_active(new_page);
> > +			if (activate >= 0)
> > +				lru_cache_add_active(new_page);
> > +			else
> > +				lru_cache_add(new_page);
> 
> This change is totally unrelated to the rest of the
> patch, and is not mentioned in the changelog.  Could
> you explain it?

Oops, you're right.  This is part of the replacement policy in
CLOCK-Pro, ARC, CART, etc. and should have been in a separate
patch.

This is what I get for pulling an all-nighter. ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
