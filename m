Message-ID: <46DF0234.7090504@redhat.com>
Date: Wed, 05 Sep 2007 15:23:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC]: pte notifiers -- support for external page tables
References: <11890103283456-git-send-email-avi@qumranet.com> <46DEFDF4.5000900@redhat.com> <46DF0013.4060804@qumranet.com>
In-Reply-To: <46DF0013.4060804@qumranet.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: linux-mm@kvack.org, shaohua.li@intel.com, kvm@qumranet.com, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Rik van Riel wrote:
> 
>>> diff --git a/mm/rmap.c b/mm/rmap.c
>>> index 41ac397..3f61d38 100644
>>> --- a/mm/rmap.c
>>> +++ b/mm/rmap.c
>>> @@ -682,6 +682,7 @@ static int try_to_unmap_one(struct page *page, 
>>> struct vm_area_struct *vma,
>>>      }
>>>  
>>>      /* Nuke the page table entry. */
>>> +    pte_notifier_call(vma, clear, address);
>>>      flush_cache_page(vma, address, page_to_pfn(page));
>>>      pteval = ptep_clear_flush(vma, address, pte);
>>
>> If you want this to be useful to Infiniband, you should probably
>> also hook up do_wp_page() in mm/memory.c, where a page table can
>> be pointed to another page.
>>
>> Probably the code in mm/mremap.c will need to be hooked up too.
>>
> 
> I imagine that many of the paravirt_ops mmu hooks will need to be 
> exposed as pte notifiers.  This can't be done as part of the 
> paravirt_ops code due to the need to pass high level data structures, 
> though.

Wait, I thought that paravirt_ops was all on the side of the
guest kernel, where these host kernel operations are invisible?

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
