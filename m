Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 6C8016B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:32:38 -0400 (EDT)
Date: Tue, 31 Jul 2012 11:23:32 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH][TRIVIAL] mm/frontswap: fix uninit'ed variable warning
Message-ID: <20120731152332.GL4789@phenom.dumpdata.com>
References: <1343677664-26665-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343677664-26665-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, trivial@kernel.org

On Mon, Jul 30, 2012 at 02:47:44PM -0500, Seth Jennings wrote:
> Fixes uninitialized variable warning on 'type' in frontswap_shrink().
> type is set before use by __frontswap_unuse_pages() called by
> __frontswap_shrink() called by frontswap_shrink() before use by
> try_to_unuse().

OK, applied.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
> Based on next-20120730
> 
>  mm/frontswap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 6b3e71a..89dc399 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -292,7 +292,7 @@ static int __frontswap_shrink(unsigned long target_pages,
>  void frontswap_shrink(unsigned long target_pages)
>  {
>  	unsigned long pages_to_unuse = 0;
> -	int type, ret;
> +	int uninitialized_var(type), ret;
>  
>  	/*
>  	 * we don't want to hold swap_lock while doing a very
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
