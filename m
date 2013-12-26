Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id BCABB6B0035
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 14:54:06 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so8189013qeb.25
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 11:54:06 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 8si15071118qal.173.2013.12.26.11.54.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Dec 2013 11:54:05 -0800 (PST)
Message-ID: <52BC8957.4000705@infradead.org>
Date: Thu, 26 Dec 2013 11:53:59 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: zswap: Add kernel parameters for zswap in kernel-parameters.txt
References: <1388061179-26624-1-git-send-email-standby24x7@gmail.com>
In-Reply-To: <1388061179-26624-1-git-send-email-standby24x7@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>, linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, linux-mm@kvack.org

On 12/26/13 04:32, Masanari Iida wrote:
> This patch adds kernel parameters for zswap.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  Documentation/kernel-parameters.txt | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 60a822b..209730af 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -3549,6 +3549,19 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			Format:
>  			<irq>,<irq_mask>,<io>,<full_duplex>,<do_sound>,<lockup_hack>[,<irq2>[,<irq3>[,<irq4>]]]
>  
> +	zswap.compressor= [KNL]
> +			Specify compressor algorithm.
> +			By default, set to lzo.

what are the options for compressor algorithm?
and does it depend on any kernel (compressor) configs?


> +
> +	zswap.enabled=	[KNL]
> +			Format: <0|1>
> +			0: Disable zswap (default)
> +			1: Enable zswap
> +			See more information, Documentations/vm/zswap.txt
> +
> +	zswap.max_pool_percent=	[KNL]
> +			The maximum percentage of memory that the compressed
> +			pool can occupy. By default, set to 20.
>  ______________________________________________________________________
>  
>  TODO:
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
