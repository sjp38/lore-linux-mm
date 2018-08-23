Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B99D6B2C76
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 18:57:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b25-v6so2852211eds.17
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 15:57:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m33-v6sor2807666edd.3.2018.08.23.15.57.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 15:57:44 -0700 (PDT)
Date: Thu, 23 Aug 2018 22:57:42 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in
 sparse_index_init()
Message-ID: <20180823225742.bsmci4gxv3dho2ke@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-2-richard.weiyang@gmail.com>
 <20180823131339.GJ29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823131339.GJ29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu, Aug 23, 2018 at 03:13:39PM +0200, Michal Hocko wrote:
>On Thu 23-08-18 21:07:30, Wei Yang wrote:
>> Each time SECTIONS_PER_ROOT number of mem_section is allocated when
>> mem_section[root] is null. This means only (1 / SECTIONS_PER_ROOT) chance
>> of the mem_section[root] check is false.
>> 
>> This patch adds likely to the if check to optimize this a little.
>
>Could you evaluate how much does this help if any? Does this have any
>impact on the initialization path at all?

Let me test on my 4G machine with this patch :-)

>
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/sparse.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 10b07eea9a6e..90bab7f03757 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -78,7 +78,7 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
>>  	struct mem_section *section;
>>  
>> -	if (mem_section[root])
>> +	if (likely(mem_section[root]))
>>  		return -EEXIST;
>>  
>>  	section = sparse_index_alloc(nid);
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
