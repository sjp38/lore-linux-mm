Subject: Re: [RFC] buddy allocator withou bitmap(2) [3/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4134573F.6060006@jp.fujitsu.com>
References: <4134573F.6060006@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093970154.26660.4829.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 31 Aug 2004 09:35:54 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-08-31 at 03:47, Hiroyuki KAMEZAWA wrote:
> "Does a page's buddy page exist or not ?" is checked by following.
> ------------------------
> if ((address of buddy is smaller than that of page) &&
>     (page->flags & PG_buddyend))
>     this page has no buddy in this order.
> ------------------------

What about the top-of-the-zone buddyend pages?  Are those covered
elsewhere?

> +static inline int page_is_buddy(struct page *page, int order)
> +{
> +	if (PagePrivate(page) &&
> +	    (page_order(page) == order) &&
> +	    !(page->flags & (1 << PG_reserved)) &&

Please use a macro.

>  	if (order)
>  		destroy_compound_page(page, order);
> +
>  	mask = (~0UL) << order;
>  	page_idx = page - base;

Repeat after me: No whitespace changes.  No whitespace changes.  No
whitespace changes.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
