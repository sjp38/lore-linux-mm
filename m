Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0446B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:15:33 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so32095441pad.10
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:15:33 -0800 (PST)
Received: from icp-osb-irony-out3.external.iinet.net.au (hosted.icp-osb-irony-out3.external.iinet.net.au. [203.59.1.153])
        by mx.google.com with ESMTP id ue4si7901359pbc.69.2015.01.28.17.15.30
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 17:15:31 -0800 (PST)
Message-ID: <54C989B6.4080006@uclinux.org>
Date: Thu, 29 Jan 2015 11:15:34 +1000
From: Greg Ungerer <gerg@uclinux.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: export "high_memory" symbol on !MMU
References: <2715923.qFZi90ffep@wuerfel>
In-Reply-To: <2715923.qFZi90ffep@wuerfel>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On 29/01/15 00:43, Arnd Bergmann wrote:
>>From f391eb37fafc8a22d7fd9574b8d220f0d90a91d0 Mon Sep 17 00:00:00 2001
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Mon, 25 Aug 2014 16:24:41 +0200
> Subject: [PATCH] mm: export "high_memory" symbol on !MMU
> 
> The symbol 'high_memory' is provided on both MMU- and NOMMU-kernels,
> but only one of them is exported, which leads to module build errors
> in drivers that work fine built-in:
> 
> ERROR: "high_memory" [drivers/net/virtio_net.ko] undefined!
> ERROR: "high_memory" [drivers/net/ppp/ppp_mppe.ko] undefined!
> ERROR: "high_memory" [drivers/mtd/nand/nand.ko] undefined!
> ERROR: "high_memory" [crypto/tcrypt.ko] undefined!
> ERROR: "high_memory" [crypto/cts.ko] undefined!
> 
> This exports the symbol to get these to work on NOMMU as well.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Here is an ack if you want one:

Acked-by: Greg Ungerer <gerg@uclinux.org>

Regards
Greg


> diff --git a/mm/nommu.c b/mm/nommu.c
> index e9228cbe46de..7bdeb281ad0e 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -59,6 +59,7 @@
>  #endif
>  
>  void *high_memory;
> +EXPORT_SYMBOL(high_memory);
>  struct page *mem_map;
>  unsigned long max_mapnr;
>  unsigned long highest_memmap_pfn;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
