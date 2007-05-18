Date: Thu, 17 May 2007 21:47:40 -0700 (PDT)
Message-Id: <20070517.214740.51856086.davem@davemloft.net>
Subject: Re: [rfc] increase struct page size?!
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070518040854.GA15654@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Fri, 18 May 2007 06:08:54 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I'd like to be the first to propose an increase to the size of struct page
> just for the sake of increasing it!
> 
> If we add 8 bytes to struct page on 64-bit machines, it becomes 64 bytes,
> which is quite a nice number for cache purposes.
> 
> However we don't have to let those 8 bytes go to waste: we can use them
> to store the virtual address of the page, which kind of makes sense for
> 64-bit, because they can likely to use complicated memory models.
> 
> I'd say all up this is going to decrease overall cache footprint in 
> fastpaths, both by reducing text and data footprint of page_address and
> related operations, and by reducing cacheline footprint of most batched
> operations on struct pages.
> 
> Flame away :)

I've toyed with this several times on sparc64, and in my experience
the extra memory reference on page->virtual costs on average about the
same as the non-power-of-2 pointer arithmetic.

The decision is absolutely arbitrary performance wise, but if you
consider the memory wastage on enormous systems going without
page->virtual I think is clearly better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
