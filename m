Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 961F96B00E7
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 20:37:38 -0400 (EDT)
Message-ID: <4F9B3BEB.1040805@xenotime.net>
Date: Fri, 27 Apr 2012 17:38:03 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: [PATCH] drivers: staging: zcache: fix Kconfig crypto dependency
References: <1335231230-29344-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1335231230-29344-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Autif Khan <autif.mlist@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 04/23/2012 06:33 PM, Seth Jennings wrote:

> ZCACHE is a boolean in the Kconfig.  When selected, it
> should require that CRYPTO be builtin (=y).
> 
> Currently, ZCACHE=y and CRYPTO=m is a valid configuration
> when it should not be.
> 
> This patch changes the zcache Kconfig to enforce this
> dependency.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>


Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.

> ---
>  drivers/staging/zcache/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
> index 3ed2c8f..7048e01 100644
> --- a/drivers/staging/zcache/Kconfig
> +++ b/drivers/staging/zcache/Kconfig
> @@ -2,7 +2,7 @@ config ZCACHE
>  	bool "Dynamic compression of swap pages and clean pagecache pages"
>  	# X86 dependency is because zsmalloc uses non-portable pte/tlb
>  	# functions
> -	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO && X86
> +	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && X86
>  	select ZSMALLOC
>  	select CRYPTO_LZO
>  	default n



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
