Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 6894F6B003A
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 02:32:05 -0400 (EDT)
Message-ID: <522976DC.8080301@oracle.com>
Date: Fri, 06 Sep 2013 14:31:56 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/4] mm/zswap: avoid unnecessary page scanning
References: <000701ceaac0$71c43590$554ca0b0$%yang@samsung.com>
In-Reply-To: <000701ceaac0$71c43590$554ca0b0$%yang@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 09/06/2013 01:16 PM, Weijie Yang wrote:
> add SetPageReclaim before __swap_writepage so that page can be moved to the
> tail of the inactive list, which can avoid unnecessary page scanning as this
> page was reclaimed by swap subsystem before.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Reviewed-by: Bob Liu <bob.liu@oracle.com>

> ---
>  mm/zswap.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 1be7b90..cc40e6a 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -556,6 +556,9 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>  		SetPageUptodate(page);
>  	}
>  
> +	/* move it to the tail of the inactive list after end_writeback */
> +	SetPageReclaim(page);
> +
>  	/* start writeback */
>  	__swap_writepage(page, &wbc, end_swap_bio_write);
>  	page_cache_release(page);
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
