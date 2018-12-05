Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 201416B7341
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 03:01:19 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so19307167qkb.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 00:01:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e127si2548996qkc.256.2018.12.05.00.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 00:01:18 -0800 (PST)
Subject: Re: [PATCH] memory_hotplug: remove duplicate declaration of
 offline_pages()
References: <20181205031357.24769-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <261ce02f-95c1-264f-40d7-eaf630f77c34@redhat.com>
Date: Wed, 5 Dec 2018 09:01:15 +0100
MIME-Version: 1.0
In-Reply-To: <20181205031357.24769-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org

On 05.12.18 04:13, Wei Yang wrote:
> Function offline_pages() is already declared in this file.
> 
> Just remove the duplicated one.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  include/linux/memory_hotplug.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index b81cc29482d8..8cf7f4a18e44 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -331,7 +331,6 @@ extern int arch_add_memory(int nid, u64 start, u64 size,
>  		struct vmem_altmap *altmap, bool want_memblock);
>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
> -extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>  extern bool is_memblock_offlined(struct memory_block *mem);
>  extern int sparse_add_one_section(int nid, unsigned long start_pfn,
>  				  struct vmem_altmap *altmap);
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
