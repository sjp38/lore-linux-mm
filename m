Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D45E6B1939
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 09:12:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t24-v6so5946659edq.13
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 06:12:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p20-v6sor4366593edq.21.2018.08.20.06.12.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 06:12:31 -0700 (PDT)
Date: Mon, 20 Aug 2018 13:12:29 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v1 5/5] mm/memory_hotplug: print only with DEBUG_VM in
 online/offline_pages()
Message-ID: <20180820131229.mloadxcqmfb3skdo@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-6-david@redhat.com>
 <20180817081853.GB17638@techadventures.net>
 <20180819123403.GA22352@WeideMacBook-Pro.local>
 <a36c4a26-658a-f57a-fdff-9fcf17fc27a6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a36c4a26-658a-f57a-fdff-9fcf17fc27a6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Oscar Salvador <osalvador@techadventures.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Aug 20, 2018 at 11:57:04AM +0200, David Hildenbrand wrote:
>On 19.08.2018 14:34, Wei Yang wrote:
>> On Fri, Aug 17, 2018 at 10:18:53AM +0200, Oscar Salvador wrote:
>>>>  failed_addition:
>>>> +#ifdef CONFIG_DEBUG_VM
>>>>  	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
>>>>  		 (unsigned long long) pfn << PAGE_SHIFT,
>>>>  		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
>>>> +#endif
>>>
>>> I have never been sure about this.
>>> IMO, if I fail to online pages, I want to know I failed.
>>> I think that pr_err would be better than pr_debug and without CONFIG_DEBUG_VM.
>>>
>>> But at least, if not, envolve it with a CONFIG_DEBUG_VM, but change pr_debug to pr_info.
>>>
>> 
>> I don't have a clear rule about these debug macro neither.
>> 
>> While when you look at the page related logs in calculate_node_totalpages(),
>> it is KERNEL_DEBUG level and without any config macro.
>> 
>> Maybe we should leave them at the same state?
>
>I guess we can do that for the to debug messages.
>
>When offlining memory right now:
>
>:/# echo 0 > /sys/devices/system/memory/memory9/online
>[   24.476207] Offlined Pages 32768
>[   24.477200] remove from free list 48000 1024 50000
>[   24.477896] remove from free list 48400 1024 50000
>[   24.478584] remove from free list 48800 1024 50000
>[   24.479454] remove from free list 48c00 1024 50000
>[   24.480192] remove from free list 49000 1024 50000
>[   24.480957] remove from free list 49400 1024 50000
>[   24.481752] remove from free list 49800 1024 50000
>[   24.482578] remove from free list 49c00 1024 50000
>[   24.483302] remove from free list 4a000 1024 50000
>[   24.484300] remove from free list 4a400 1024 50000
>[   24.484902] remove from free list 4a800 1024 50000
>[   24.485462] remove from free list 4ac00 1024 50000
>[   24.486381] remove from free list 4b000 1024 50000
>[   24.487108] remove from free list 4b400 1024 50000
>[   24.487842] remove from free list 4b800 1024 50000
>[   24.488610] remove from free list 4bc00 1024 50000
>[   24.489548] remove from free list 4c000 1024 50000
>[   24.490392] remove from free list 4c400 1024 50000
>[   24.491224] remove from free list 4c800 1024 50000
>...
>
>While "remove from free list" is pr_info under CONFIG_DEBUG_VM,
>"Offlined Pages ..." is pr_info without CONFIG_DEBUG_VM.

Hmm... yes, don't see the logic between them.

>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me
