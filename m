Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32E586B5592
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 20:22:27 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i14so2040738edf.17
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 17:22:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u11-v6sor1236160ejb.36.2018.11.29.17.22.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 17:22:25 -0800 (PST)
Date: Fri, 30 Nov 2018 01:22:23 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 2/2] mm, sparse: pass nid instead of pgdat to
 sparse_add_one_section()
Message-ID: <20181130012223.bfekdl2b3tghkvji@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <20181129155316.8174-2-richard.weiyang@gmail.com>
 <7acfdb10-9e4e-a766-fb6f-08c575887167@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7acfdb10-9e4e-a766-fb6f-08c575887167@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Nov 29, 2018 at 05:01:51PM +0100, David Hildenbrand wrote:
>On 29.11.18 16:53, Wei Yang wrote:
>> Since the information needed in sparse_add_one_section() is node id to
>> allocate proper memory, it is not necessary to pass its pgdat.
>> 
>> This patch changes the prototype of sparse_add_one_section() to pass
>> node id directly. This is intended to reduce misleading that
>> sparse_add_one_section() would touch pgdat.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  include/linux/memory_hotplug.h | 2 +-
>>  mm/memory_hotplug.c            | 2 +-
>>  mm/sparse.c                    | 6 +++---
>>  3 files changed, 5 insertions(+), 5 deletions(-)
>> 
>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>> index 45a5affcab8a..3787d4e913e6 100644
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -333,7 +333,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>>  extern bool is_memblock_offlined(struct memory_block *mem);
>> -extern int sparse_add_one_section(struct pglist_data *pgdat,
>> +extern int sparse_add_one_section(int nid,
>>  		unsigned long start_pfn, struct vmem_altmap *altmap);
>
>While you touch that, can you fixup the alignment of the other parameters?
>

If I am correct, the code style of alignment is like this?

extern int sparse_add_one_section(int nid, unsigned long start_pfn,
				  struct vmem_altmap *altmap);

>Apart from that
>
>Reviewed-by: David Hildenbrand <david@redhat.com>
>

-- 
Wei Yang
Help you, Help me
