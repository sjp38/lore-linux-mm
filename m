Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 42E4B6B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 00:55:41 -0400 (EDT)
Date: Wed, 8 Aug 2012 13:57:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] zsmalloc: s/firstpage/page in new copy map funcs
Message-ID: <20120808045712.GE4247@bbox>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hi Greg,

When do you merge this series?
Thanks.

On Wed, Jul 18, 2012 at 11:55:54AM -0500, Seth Jennings wrote:
> firstpage already has precedent and meaning the first page
> of a zspage.  In the case of the copy mapping functions,
> it is the first of a pair of pages needing to be mapped.
> 
> This patch just renames the firstpage argument to "page" to
> avoid confusion.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 8b0bcb6..3c83c65 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -470,15 +470,15 @@ static struct page *find_get_zspage(struct size_class *class)
>  	return page;
>  }
>  
> -static void zs_copy_map_object(char *buf, struct page *firstpage,
> +static void zs_copy_map_object(char *buf, struct page *page,
>  				int off, int size)
>  {
>  	struct page *pages[2];
>  	int sizes[2];
>  	void *addr;
>  
> -	pages[0] = firstpage;
> -	pages[1] = get_next_page(firstpage);
> +	pages[0] = page;
> +	pages[1] = get_next_page(page);
>  	BUG_ON(!pages[1]);
>  
>  	sizes[0] = PAGE_SIZE - off;
> @@ -493,15 +493,15 @@ static void zs_copy_map_object(char *buf, struct page *firstpage,
>  	kunmap_atomic(addr);
>  }
>  
> -static void zs_copy_unmap_object(char *buf, struct page *firstpage,
> +static void zs_copy_unmap_object(char *buf, struct page *page,
>  				int off, int size)
>  {
>  	struct page *pages[2];
>  	int sizes[2];
>  	void *addr;
>  
> -	pages[0] = firstpage;
> -	pages[1] = get_next_page(firstpage);
> +	pages[0] = page;
> +	pages[1] = get_next_page(page);
>  	BUG_ON(!pages[1]);
>  
>  	sizes[0] = PAGE_SIZE - off;
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
