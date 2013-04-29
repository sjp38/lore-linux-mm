Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 87A586B009B
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 16:46:21 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id ha11so2176752vcb.23
        for <linux-mm@kvack.org>; Mon, 29 Apr 2013 13:46:20 -0700 (PDT)
Message-ID: <517EDC19.7020705@gmail.com>
Date: Mon, 29 Apr 2013 16:46:17 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add an option to disable bounce
References: <1366644180-6140-1-git-send-email-vinayakm.list@gmail.com>
In-Reply-To: <1366644180-6140-1-git-send-email-vinayakm.list@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayakm.list@gmail.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(4/22/13 11:23 AM), vinayakm.list@gmail.com wrote:
> From: Vinayak Menon <vinayakm.list@gmail.com>
> 
> There are times when HIGHMEM is enabled, but
> we don't prefer CONFIG_BOUNCE to be enabled.
> CONFIG_BOUNCE can reduce the block device
> throughput, and this is not ideal for machines
> where we don't gain much by enabling it. So
> provide an option to deselect CONFIG_BOUNCE. The
> observation was made while measuring eMMC throughput
> using iozone on an ARM device with 1GB RAM.
> 
> Signed-off-by: Vinayak Menon <vinayakm.list@gmail.com>
> ---
>  mm/Kconfig |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 3bea74f..29f9736 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -263,8 +263,14 @@ config ZONE_DMA_FLAG
>  	default "1"
>  
>  config BOUNCE
> +	bool "Enable bounce buffers"
>  	def_bool y
>  	depends on BLOCK && MMU && (ZONE_DMA || HIGHMEM)
> +	help
> +	  Enable bounce buffers for devices that cannot access
> +	  the full range of memory available to the CPU. Enabled
> +	  by default when ZONE_DMA or HIGMEM is selected, but you
> +	  may say n to override this.

This should depend on CONFIG_EXPERT. Because this makes typically worse result
on typical desktop machine.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
