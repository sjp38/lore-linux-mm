Date: Thu, 28 Sep 2006 20:14:55 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [TRIVIAL PATCH] mm: Make filemap_nopage use NOPAGE_SIGBUS
In-Reply-To: <1159470592.12797.23334.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0609282013360.9244@blonde.wat.veritas.com>
References: <1159470592.12797.23334.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2006, Adam Litke wrote:
> Hi Andrew.  This is just a "nice to have" cleanup patch.  Any chance on
> getting it merged (lest I forget about it again)?  Thanks.
> 
> While reading trough filemap_nopage() I found the 'return NULL'
> statements a bit confusing since we already have two constants defined
> for ->nopage error conditions.  Since a NULL return value really means
> NOPAGE_SIGBUS, just return that to make the code more readable.
> 
> Signed-off-by: Adam Litke <agl@us.ibm.com> 

That's long confused and irritated me, gladly
Acked-by: Hugh Dickins <hugh@veritas.com>

> 
>  filemap.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> diff -upN reference/mm/filemap.c current/mm/filemap.c
> --- reference/mm/filemap.c
> +++ current/mm/filemap.c
> @@ -1454,7 +1454,7 @@ outside_data_content:
>  	 * accessible..
>  	 */
>  	if (area->vm_mm == current->mm)
> -		return NULL;
> +		return NOPAGE_SIGBUS;
>  	/* Fall through to the non-read-ahead case */
>  no_cached_page:
>  	/*
> @@ -1479,7 +1479,7 @@ no_cached_page:
>  	 */
>  	if (error == -ENOMEM)
>  		return NOPAGE_OOM;
> -	return NULL;
> +	return NOPAGE_SIGBUS;
>  
>  page_not_uptodate:
>  	if (!did_readaround) {
> @@ -1548,7 +1548,7 @@ page_not_uptodate:
>  	 */
>  	shrink_readahead_size_eio(file, ra);
>  	page_cache_release(page);
> -	return NULL;
> +	return NOPAGE_SIGBUS;
>  }
>  EXPORT_SYMBOL(filemap_nopage);
>  
> -- 
> Adam Litke - (agl at us.ibm.com)
> IBM Linux Technology Center
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
