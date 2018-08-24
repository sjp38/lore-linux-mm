Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 879F56B2CCA
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 20:11:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o16-v6so4153113pgv.21
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 17:11:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d16-v6si6065417pfe.267.2018.08.23.17.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 17:11:49 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in
 sparse_index_init()
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-2-richard.weiyang@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cc817bc8-bced-fb07-cb2d-c122463380a7@intel.com>
Date: Thu, 23 Aug 2018 17:11:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180823130732.9489-2-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On 08/23/2018 06:07 AM, Wei Yang wrote:
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -78,7 +78,7 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
>  	struct mem_section *section;
>  
> -	if (mem_section[root])
> +	if (likely(mem_section[root]))
>  		return -EEXIST;

We could add likely()/unlikely() to approximately a billion if()s around
the kernel if we felt like it.  We don't because it's messy and it
actually takes away choices from the compiler.

Please don't send patches like this unless you have some *actual*
analysis that shows the benefit of the patch.  Performance numbers are best.
