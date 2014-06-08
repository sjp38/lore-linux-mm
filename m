Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 017446B0036
	for <linux-mm@kvack.org>; Sun,  8 Jun 2014 18:25:53 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id l13so3200855iga.4
        for <linux-mm@kvack.org>; Sun, 08 Jun 2014 15:25:53 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id m8si18622522igv.31.2014.06.08.15.25.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 08 Jun 2014 15:25:53 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id r2so1255724igi.0
        for <linux-mm@kvack.org>; Sun, 08 Jun 2014 15:25:53 -0700 (PDT)
Date: Sun, 8 Jun 2014 15:25:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
In-Reply-To: <20140608181436.17de69ac@redhat.com>
Message-ID: <alpine.DEB.2.02.1406081524580.21744@chino.kir.corp.google.com>
References: <20140608181436.17de69ac@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: akpm@linux-foundation.org, andi@firstfloor.org, riel@redhat.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Sun, 8 Jun 2014, Luiz Capitulino wrote:

> diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
> index 4064aca..01b493e 100644
> --- a/arch/x86/include/asm/numa.h
> +++ b/arch/x86/include/asm/numa.h
> @@ -9,7 +9,6 @@
>  #ifdef CONFIG_NUMA
>  
>  #define NR_NODE_MEMBLKS		(MAX_NUMNODES*2)
> -#define ZONE_ALIGN (1UL << (MAX_ORDER+PAGE_SHIFT))
>  
>  /*
>   * Too small node sizes may confuse the VM badly. Usually they
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 1d045f9..69f6362 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -200,8 +200,6 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
>  	if (end && (end - start) < NODE_MIN_SIZE)
>  		return;
>  
> -	start = roundup(start, ZONE_ALIGN);
> -
>  	printk(KERN_INFO "Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
>  	       nid, start, end - 1);
>  

What ensures this start address is page aligned from the BIOS?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
