Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8D46B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 01:29:09 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so140221176pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 22:29:09 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id rt4si43270418pbb.18.2015.09.21.22.29.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 22:29:08 -0700 (PDT)
Message-ID: <1442899743.18408.5.camel@ellerman.id.au>
Subject: Re: [PATCH V2  2/2] powerpc:numa Do not allocate bootmem memory for
 non existing nodes
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 22 Sep 2015 15:29:03 +1000
In-Reply-To: <1442282917-16893-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: 
	<1442282917-16893-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <1442282917-16893-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2015-09-15 at 07:38 +0530, Raghavendra K T wrote:
>
> ... nothing

Sure this patch looks obvious, but please give me a changelog that proves
you've thought about it thoroughly.

For example is it OK to use for_each_node() at this point in boot? Is there any
historical reason why we did it with a hard coded loop? If so what has changed.
What systems have you tested on? etc. etc.

cheers

> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/numa.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index 8b9502a..8d8a541 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -80,7 +80,7 @@ static void __init setup_node_to_cpumask_map(void)
>  		setup_nr_node_ids();
>  
>  	/* allocate the map */
> -	for (node = 0; node < nr_node_ids; node++)
> +	for_each_node(node)
>  		alloc_bootmem_cpumask_var(&node_to_cpumask_map[node]);
>  
>  	/* cpumask_of_node() will now work */




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
