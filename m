Date: Mon, 6 Mar 2006 17:58:10 -0800
From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: Re: [PATCH] avoid atomic op on page free
Message-ID: <20060307015810.GK32565@linux.intel.com>
References: <20060307001015.GG32565@linux.intel.com> <440CE797.1010303@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <440CE797.1010303@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 07, 2006 at 12:53:27PM +1100, Nick Piggin wrote:
> You can't do this because you can't test PageLRU like that.
> 
> Have a look in the lkml archives a few months back, where I proposed
> a way to do this for __free_pages(). You can't do it for put_page.

Even if we know that we are the last user of the page (the count is 1)?  
Who can bump the page's count then?

> BTW I have quite a large backlog of patches in -mm which should end
> up avoiding an atomic or two around these parts.

That certainly looks like it will help.  Not taking the spinlock 
unconditionally gets rid of quite a bit of the cost.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
