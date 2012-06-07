Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id D97CB6B0062
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 14:38:47 -0400 (EDT)
Date: Thu, 7 Jun 2012 14:31:45 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 07/11] mm: frontswap: remove unnecessary check during
 initialization
Message-ID: <20120607183145.GB9472@phenom.dumpdata.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
 <1338980115-2394-7-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338980115-2394-7-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 06, 2012 at 12:55:11PM +0200, Sasha Levin wrote:

Could you explain in the git commit why it is unnecessary?
I am pretty sure I know - it is b/c frontswap_init already
does the check, but the git commit should mention it.

> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  mm/frontswap.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index f2f4685..bf99c7d 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -89,8 +89,7 @@ void __frontswap_init(unsigned type)
>  	BUG_ON(sis == NULL);
>  	if (sis->frontswap_map == NULL)
>  		return;
> -	if (frontswap_enabled)
> -		frontswap_ops.init(type);
> +	frontswap_ops.init(type);
>  }
>  EXPORT_SYMBOL(__frontswap_init);
>  
> -- 
> 1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
