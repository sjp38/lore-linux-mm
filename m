Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 544476B576F
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:20:32 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z68so4699886qkb.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 01:20:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q4si67165qkj.161.2018.11.30.01.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 01:20:31 -0800 (PST)
Subject: Re: [PATCH v3 2/2] mm, sparse: pass nid instead of pgdat to
 sparse_add_one_section()
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <20181129155316.8174-2-richard.weiyang@gmail.com>
 <7acfdb10-9e4e-a766-fb6f-08c575887167@redhat.com>
 <20181130012223.bfekdl2b3tghkvji@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <ed1263d6-0d10-d1b7-8c19-cafcef384cc3@redhat.com>
Date: Fri, 30 Nov 2018 10:20:28 +0100
MIME-Version: 1.0
In-Reply-To: <20181130012223.bfekdl2b3tghkvji@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On 30.11.18 02:22, Wei Yang wrote:
> On Thu, Nov 29, 2018 at 05:01:51PM +0100, David Hildenbrand wrote:
>> On 29.11.18 16:53, Wei Yang wrote:
>>> Since the information needed in sparse_add_one_section() is node id to
>>> allocate proper memory, it is not necessary to pass its pgdat.
>>>
>>> This patch changes the prototype of sparse_add_one_section() to pass
>>> node id directly. This is intended to reduce misleading that
>>> sparse_add_one_section() would touch pgdat.
>>>
>>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>>> ---
>>>  include/linux/memory_hotplug.h | 2 +-
>>>  mm/memory_hotplug.c            | 2 +-
>>>  mm/sparse.c                    | 6 +++---
>>>  3 files changed, 5 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>>> index 45a5affcab8a..3787d4e913e6 100644
>>> --- a/include/linux/memory_hotplug.h
>>> +++ b/include/linux/memory_hotplug.h
>>> @@ -333,7 +333,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>>>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>>>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>>>  extern bool is_memblock_offlined(struct memory_block *mem);
>>> -extern int sparse_add_one_section(struct pglist_data *pgdat,
>>> +extern int sparse_add_one_section(int nid,
>>>  		unsigned long start_pfn, struct vmem_altmap *altmap);
>>
>> While you touch that, can you fixup the alignment of the other parameters?
>>
> 
> If I am correct, the code style of alignment is like this?
> 
> extern int sparse_add_one_section(int nid, unsigned long start_pfn,
> 				  struct vmem_altmap *altmap);

Yes, all parameters should start at the same indentation. (some people
don't care and produce this "mess", I tend to care :) )

> 
>> Apart from that
>>
>> Reviewed-by: David Hildenbrand <david@redhat.com>
>>
> 


-- 

Thanks,

David / dhildenb
