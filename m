Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id DD1A26B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 13:13:48 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 16 May 2012 11:13:47 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BBD94C9007B
	for <linux-mm@kvack.org>; Wed, 16 May 2012 13:12:28 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4GHCUqZ117972
	for <linux-mm@kvack.org>; Wed, 16 May 2012 13:12:31 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4GHBvto004165
	for <linux-mm@kvack.org>; Wed, 16 May 2012 11:11:57 -0600
Message-ID: <4FB3DFDB.80605@linux.vnet.ibm.com>
Date: Wed, 16 May 2012 12:11:55 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/3] remove dependency with x86
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1337133919-4182-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/15/2012 09:05 PM, Minchan Kim wrote:

> Exactly saying, [zram|zcache] should has a dependency with
> zsmalloc, not x86. So replace x86 dependeny with ZSMALLOC.
> 
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zcache/Kconfig |    3 +--
>  drivers/staging/zram/Kconfig   |    3 +--
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
> index 7048e01..ceb7f28 100644
> --- a/drivers/staging/zcache/Kconfig
> +++ b/drivers/staging/zcache/Kconfig
> @@ -2,8 +2,7 @@ config ZCACHE
>  	bool "Dynamic compression of swap pages and clean pagecache pages"
>  	# X86 dependency is because zsmalloc uses non-portable pte/tlb
>  	# functions
> -	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && X86
> -	select ZSMALLOC
> +	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && ZSMALLOC


Sorry Minchan, I should have said this the first time around.  I ran
into this issue before with CRYTPO vs CRYPTO=y.  ZCACHE is a bool where
ZSMALLOC is a tristate.  It is not sufficient for ZSMALLOC to be set; it
_must_ be builtin, otherwise you get linker errors.

The dependency should be ZSMALLOC=y.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
