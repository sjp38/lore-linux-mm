Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DF39F6B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:42:33 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 14 May 2012 08:42:32 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 9EBE4C90057
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:42:25 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4EEgSNQ116398
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:42:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4EKDFWc011942
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:13:20 -0400
Message-ID: <4FB119CA.2080606@linux.vnet.ibm.com>
Date: Mon, 14 May 2012 09:42:18 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] zram: remove comment in Kconfig
References: <1336985134-31967-1-git-send-email-minchan@kernel.org> <1336985134-31967-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1336985134-31967-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/14/2012 03:45 AM, Minchan Kim wrote:

> Exactly speaking, zram should has dependency with
> zsmalloc, not x86. So x86 dependeny check is redundant.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zram/Kconfig |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
> index 9d11a4c..ee23a86 100644
> --- a/drivers/staging/zram/Kconfig
> +++ b/drivers/staging/zram/Kconfig
> @@ -1,8 +1,6 @@
>  config ZRAM
>  	tristate "Compressed RAM block device support"
> -	# X86 dependency is because zsmalloc uses non-portable pte/tlb
> -	# functions
> -	depends on BLOCK && SYSFS && X86
> +	depends on BLOCK && SYSFS


Two comments here:

1) zram should really depend on ZSMALLOC instead of selecting it
because, as the patch has it, zram could be selected on an arch that
zsmalloc doesn't support.

2) This change would need to be done in zcache as well.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
