Date: Wed, 17 Sep 2003 12:32:02 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: __vmalloc and alloc_page
Message-ID: <20030917193202.GG14079@holomorphy.com>
References: <200309171326.11848.lmb@exatas.unisinos.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200309171326.11848.lmb@exatas.unisinos.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Leandro Motta Barros <lmb@exatas.unisinos.br>
Cc: linux-mm@kvack.org, sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 17, 2003 at 01:26:11PM -0300, Leandro Motta Barros wrote:
> Thanks for the feedback on the previous email. Well, there is another
> thing we thought that could be done. '__vmalloc()' allocates its
> memory by calling 'alloc_page()' for every necessary page. Wouldn't
> it be better calling 'alloc_pages()' to allocate more pages at once
> whenever possible? We would need more bookeepping, and sometimes it
> could be necessary to actually allocate the memory page per page, but
> we think this approach could be a way to use memory blocks of higher order.
> Do you think this is feasible or useful?
> Also, we would like to know if you have suggestions on topics that we could 
> explore and implement.

Higher-order would probably not be as useful as you'd suspect; try
looking at the distribution of available pages of given sizes in /proc/.
OTOH, just being able to get more than one page in one call (not relying
on physically contiguous memory) would be a simple and useful optimization.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
