Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 449316B0033
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 13:47:23 -0400 (EDT)
Date: Mon, 22 Apr 2013 18:47:12 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] mm: add an option to disable bounce
Message-ID: <20130422174712.GS14496@n2100.arm.linux.org.uk>
References: <1366644180-6140-1-git-send-email-vinayakm.list@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366644180-6140-1-git-send-email-vinayakm.list@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayakm.list@gmail.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, rientjes@google.com

On Mon, Apr 22, 2013 at 08:53:00PM +0530, vinayakm.list@gmail.com wrote:
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

I don't think this is correct.  You shouldn't use "bool" with "def_bool".
Sure, add the "bool", but also change "def_bool" to "default".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
