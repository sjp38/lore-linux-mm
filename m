Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB23A6B2A1B
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:21:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j15-v6so3180602pff.12
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:21:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p38-v6si4488023pgm.596.2018.08.23.06.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 06:21:15 -0700 (PDT)
Date: Thu, 23 Aug 2018 15:21:12 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/3] mm/sparse: expand the CONFIG_SPARSEMEM_EXTREME range
 in __nr_to_section()
Message-ID: <20180823132112.GK29735@dhcp22.suse.cz>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-3-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823130732.9489-3-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com, Dave Hansen <dave.hansen@intel.com>

[Cc Dave]

On Thu 23-08-18 21:07:31, Wei Yang wrote:
> When CONFIG_SPARSEMEM_EXTREME is not defined, mem_section is a static
> two dimension array. This means !mem_section[SECTION_NR_TO_ROOT(nr)] is
> always true.
> 
> This patch expand the CONFIG_SPARSEMEM_EXTREME range to return a proper
> mem_section when CONFIG_SPARSEMEM_EXTREME is not defined.

As long as all callers provide a valid section number then yes. I am not
really sure this is the case though.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  include/linux/mmzone.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 32699b2dc52a..33086f86d1a7 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1155,9 +1155,9 @@ static inline struct mem_section *__nr_to_section(unsigned long nr)
>  #ifdef CONFIG_SPARSEMEM_EXTREME
>  	if (!mem_section)
>  		return NULL;
> -#endif
>  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
>  		return NULL;
> +#endif
>  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
>  }
>  extern int __section_nr(struct mem_section* ms);
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
