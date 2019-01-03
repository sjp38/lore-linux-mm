Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1377B8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:15:05 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so35222961pfj.3
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:15:05 -0800 (PST)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id d15si50467134pgt.498.2019.01.03.09.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:15:03 -0800 (PST)
Subject: Re: [v4 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546145375-793-2-git-send-email-yang.shi@linux.alibaba.com>
 <875zv6w5m6.fsf@yhuang-dev.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ac47b98e-4418-7f61-bb90-4311f3b5dc2b@linux.alibaba.com>
Date: Thu, 3 Jan 2019 09:12:52 -0800
MIME-Version: 1.0
In-Reply-To: <875zv6w5m6.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/2/19 11:41 PM, Huang, Ying wrote:
> Yang Shi <yang.shi@linux.alibaba.com> writes:
>
>> swap_vma_readahead()'s comment is missed, just add it.
>>
>> Cc: Huang Ying <ying.huang@intel.com>
>> Cc: Tim Chen <tim.c.chen@intel.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   mm/swap_state.c | 17 +++++++++++++++++
>>   1 file changed, 17 insertions(+)
>>
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index 78d500e..dd8f698 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -698,6 +698,23 @@ static void swap_ra_info(struct vm_fault *vmf,
>>   	pte_unmap(orig_pte);
>>   }
>>   
>> +/**
>> + * swap_vm_readahead - swap in pages in hope we need them soon
> s/swap_vm_readahead/swap_vma_readahead/
>
>> + * @entry: swap entry of this memory
>> + * @gfp_mask: memory allocation flags
>> + * @vmf: fault information
>> + *
>> + * Returns the struct page for entry and addr, after queueing swapin.
>> + *
>> + * Primitive swap readahead code. We simply read in a few pages whoes
>> + * virtual addresses are around the fault address in the same vma.
>> + *
>> + * This has been extended to use the NUMA policies from the mm triggering
>> + * the readahead.
> What is this?  I know you copy it from swap_cluster_readahead(), but we
> have only one mm for vma readahead.

Aha, I see. Actually I was confused by this too, so just copied from 
swap_cluster_readahead.

>
>> + * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
> Better to make it explicit that your are talking about mmap_sem?

Sure.

Thanks,
Yang

>
> Best Regards,
> Huang, Ying
>
>> + *
>> + */
>>   static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>>   				       struct vm_fault *vmf)
>>   {
