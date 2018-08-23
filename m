Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3873F6B2C7E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 19:03:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z56-v6so2897534edz.10
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 16:03:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12-v6sor2742206edi.55.2018.08.23.16.03.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 16:03:19 -0700 (PDT)
Date: Thu, 23 Aug 2018 23:03:17 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/3] mm/sparse: expand the CONFIG_SPARSEMEM_EXTREME range
 in __nr_to_section()
Message-ID: <20180823230317.swgcn6d7uokbd6zo@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-3-richard.weiyang@gmail.com>
 <20180823132112.GK29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823132112.GK29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com, Dave Hansen <dave.hansen@intel.com>

On Thu, Aug 23, 2018 at 03:21:12PM +0200, Michal Hocko wrote:
>[Cc Dave]
>
>On Thu 23-08-18 21:07:31, Wei Yang wrote:
>> When CONFIG_SPARSEMEM_EXTREME is not defined, mem_section is a static
>> two dimension array. This means !mem_section[SECTION_NR_TO_ROOT(nr)] is
>> always true.
>> 
>> This patch expand the CONFIG_SPARSEMEM_EXTREME range to return a proper
>> mem_section when CONFIG_SPARSEMEM_EXTREME is not defined.
>
>As long as all callers provide a valid section number then yes. I am not
>really sure this is the case though.
>

I don't get your point.

When CONFIG_SPARSEMEM_EXTREME is not defined, each section number is a
valid one in this context. Because for eavry section number in
[0, NR_MEM_SECTIONS - 1], we have a mem_sectioin structure there.

This patch helps to reduce a meaningless check when
CONFIG_SPARSEMEM_EXTREME=n.

>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  include/linux/mmzone.h | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 32699b2dc52a..33086f86d1a7 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -1155,9 +1155,9 @@ static inline struct mem_section *__nr_to_section(unsigned long nr)
>>  #ifdef CONFIG_SPARSEMEM_EXTREME
>>  	if (!mem_section)
>>  		return NULL;
>> -#endif
>>  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
>>  		return NULL;
>> +#endif
>>  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
>>  }
>>  extern int __section_nr(struct mem_section* ms);
>> -- 
>> 2.15.1
>> 
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
