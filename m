Date: Fri, 27 Jun 2003 21:35:35 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: shrink_caches()
Message-Id: <20030627213535.56c0ab4a.akpm@digeo.com>
In-Reply-To: <Pine.GSO.4.50.0306261315060.26256-100000@aloha.cc.columbia.edu>
References: <Pine.GSO.4.50.0306261315060.26256-100000@aloha.cc.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Raghu R Arur <rra2002@columbia.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Raghu R Arur <rra2002@columbia.edu> wrote:
>
> I was going thru the code of shrink_caches(). it returns the difference
>  between the number of pages requested to be freed and the number of pages
>  that were actually freed. What i see over here is that the nr_pages which
>  is the return value, is decremented only when the pages are freed from
>  slab cache and page cache. The value is not decremented when the pages get
>  freed from dentry cache, inode cache or the quota cache, which are freed
>  at high memory pressure times. So when no pages get freed from page cache,
>  but get freed from dentry/inode caches we will be returning a value which
>  says that no pages were freed. Why is this done? can you PLEASE explain me
>  this.

yes, it is an oversight.    it's fixed in 2.5.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
