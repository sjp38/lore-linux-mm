Subject: Re: [patch 3/8] mm: rotate_reclaimable_page() cleanup
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080317191944.208962764@szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191944.208962764@szeredi.hu>
Content-Type: text/plain
Date: Tue, 18 Mar 2008 12:31:36 +0100
Message-Id: <1205839896.8514.344.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 20:19 +0100, Miklos Szeredi wrote:
> plain text document attachment (rotate_reclaimable_page_cleanup.patch)
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> Clean up messy conditional calling of test_clear_page_writeback() from
> both rotate_reclaimable_page() and end_page_writeback().

> -int rotate_reclaimable_page(struct page *page)
> +void  rotate_reclaimable_page(struct page *page)
>  {
> -	struct pagevec *pvec;
> -	unsigned long flags;
> -
> -	if (PageLocked(page))
> -		return 1;
> -	if (PageDirty(page))
> -		return 1;
> -	if (PageActive(page))
> -		return 1;
> -	if (!PageLRU(page))
> -		return 1;

Might be me, but I find the above easier to read than

> +	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
> +	    PageLRU(page)) {
>  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
