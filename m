Message-ID: <46DF0013.4060804@qumranet.com>
Date: Wed, 05 Sep 2007 22:14:27 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC]: pte notifiers -- support for external page tables
References: <11890103283456-git-send-email-avi@qumranet.com> <46DEFDF4.5000900@redhat.com>
In-Reply-To: <46DEFDF4.5000900@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, shaohua.li@intel.com, kvm@qumranet.com, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 41ac397..3f61d38 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -682,6 +682,7 @@ static int try_to_unmap_one(struct page *page, 
>> struct vm_area_struct *vma,
>>      }
>>  
>>      /* Nuke the page table entry. */
>> +    pte_notifier_call(vma, clear, address);
>>      flush_cache_page(vma, address, page_to_pfn(page));
>>      pteval = ptep_clear_flush(vma, address, pte);
>
> If you want this to be useful to Infiniband, you should probably
> also hook up do_wp_page() in mm/memory.c, where a page table can
> be pointed to another page.
>
> Probably the code in mm/mremap.c will need to be hooked up too.
>

I imagine that many of the paravirt_ops mmu hooks will need to be 
exposed as pte notifiers.  This can't be done as part of the 
paravirt_ops code due to the need to pass high level data structures, 
though.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
