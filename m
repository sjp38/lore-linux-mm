Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1B56B0006
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:25:29 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t17-v6so10480023ply.13
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:25:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r24-v6si15320788pfi.147.2018.06.18.10.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Jun 2018 10:25:28 -0700 (PDT)
Subject: Re: [PATCH 04/11] docs/mm: bootmem: add kernel-doc description of
 'struct bootmem_data'
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1529341199-17682-5-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <f276789a-f6c0-6a98-5e21-3c3c15112e80@infradead.org>
Date: Mon, 18 Jun 2018 10:25:21 -0700
MIME-Version: 1.0
In-Reply-To: <1529341199-17682-5-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On 06/18/2018 09:59 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  include/linux/bootmem.h | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index 7942a96..1526ba1 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -27,9 +27,20 @@ extern unsigned long max_pfn;
>  extern unsigned long long max_possible_pfn;
>  
>  #ifndef CONFIG_NO_BOOTMEM
> -/*
> - * node_bootmem_map is a map pointer - the bits represent all physical 
> - * memory pages (including holes) on the node.
> +/**
> + * struct bootmem_data - per-node information used by the bootmem allocator
> + * @node_min_pfn: the starting physical address of the node's memory
> + * @node_low_pfn: the end physical address of the directly addressable memory
> + * @node_bootmem_map: is a bitmap pointer - the bits represent all physical
> + *		     memory pages (including holes) on the node.
> + * @last_end_off: the offset within the page of the end of the last allocation;
> + *                if 0, the page used is full
> + * @hint_idx: the the PFN of the page used with the last allocation;

            drop one "the" above.

> + *	       together with using this with the @last_end_offset field,
> + *	       a test can be made to see if allocations can be merged
> + *	       with the page used for the last allocation rather than
> + *	       using up a full new page.
> + * @list: list entry in the linked list ordered by the memory addresses
>   */
>  typedef struct bootmem_data {
>  	unsigned long node_min_pfn;
> 


-- 
~Randy
