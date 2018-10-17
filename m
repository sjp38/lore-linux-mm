Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA08E6B0006
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:45:56 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l75-v6so26658730qke.23
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:45:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r23-v6si6894478qte.383.2018.10.17.02.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 02:45:55 -0700 (PDT)
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory
 functions
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-3-osalvador@techadventures.net>
 <d0a12eb5-3824-8d25-75f8-3e62f1e81994@redhat.com>
 <20181017093331.GA25724@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <883d3ab7-b2df-9b9a-7681-1019ce3b9e18@redhat.com>
Date: Wed, 17 Oct 2018 11:45:50 +0200
MIME-Version: 1.0
In-Reply-To: <20181017093331.GA25724@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

On 17/10/2018 11:33, Oscar Salvador wrote:
>>>  	/*
>>>  	 * For device private memory we call add_pages() as we only need to
>>>  	 * allocate and initialize struct page for the device memory. More-
>>> @@ -1096,20 +1100,17 @@ static int hmm_devmem_pages_create(struct hmm_devmem *devmem)
>>>  	 * want the linear mapping and thus use arch_add_memory().
>>>  	 */
>>
>> Some parts of this comment should be moved into add_device_memory now.
>> (e.g. we call add_pages() ...)
> 
> I agree.
> 
>>> +#ifdef CONFIG_ZONE_DEVICE
>>> +int del_device_memory(int nid, unsigned long start, unsigned long size,
>>> +				struct vmem_altmap *altmap, bool mapping)
>>> +{
>>> +	int ret;
>>
>> nit: personally I prefer short parameters last in the list.
> 
> I do not have a strong opinion here.
> If people think that long parameters should be placed at the end because
> it improves readability, I am ok with moving them there.
>  
>> Can you document for both functions that they should be called with the
>> memory hotplug lock in write?
> 
> Sure, I will do that in the next version, once I get some more feedback.
> 
>> Apart from that looks good to me.
> 
> Thanks for reviewing it David ;-)!
> May I assume your Reviewed-by here (if the above comments are addressed)?

Here you go ;)

Reviewed-by: David Hildenbrand <david@redhat.com>

I'm planning to look into the other patches as well, but I'll be busy
with traveling and KVM forum the next 1.5 weeks.

Cheers!


-- 

Thanks,

David / dhildenb
