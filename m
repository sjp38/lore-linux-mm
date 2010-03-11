Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 834876B00BE
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 03:55:56 -0500 (EST)
Message-ID: <4B98B018.4020103@redhat.com>
Date: Thu, 11 Mar 2010 10:55:52 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm : remove redundant initialization of page->private
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com>	 <1268065219.1254.12.camel@barrios-desktop>  <4B977244.4010603@redhat.com> <1268231482.1254.28.camel@barrios-desktop> <4B989EE2.30803@redhat.com> <4B98AF1B.80701@siemens.com>
In-Reply-To: <4B98AF1B.80701@siemens.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 03/11/2010 10:51 AM, Jan Kiszka wrote:
> Avi Kivity wrote:
>    
>> On 03/10/2010 04:31 PM, Minchan Kim wrote:
>>      
>>> The prep_new_page() in page allocator calls set_page_private(page, 0).
>>> So we don't need to reinitialize private of page.
>>>
>>>
>>>        
>> Applied, thanks.  Please copy the kvm mailing list in the future on kvm
>> patches.
>>
>>      
>>> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
>>> index 741373e..9851d0e 100644
>>> --- a/arch/x86/kvm/mmu.c
>>> +++ b/arch/x86/kvm/mmu.c
>>> @@ -326,7 +326,6 @@ static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
>>>    		page = alloc_page(GFP_KERNEL);
>>>    		if (!page)
>>>    			return -ENOMEM;
>>> -		set_page_private(page, 0);
>>>    		cache->objects[cache->nobjs++] = page_address(page);
>>>    	}
>>>    	return 0;
>>>
>>>        
>> Jan, this is kvm-kmod unfriendly.  kvm_alloc_page()?
>>
>>      
> Thanks for pointing out! Since which kernel can we rely on the implicit
> set_page_private?
>
>    

Um, git blame shows it goes all the way back to 2.6.12.  So it was 
redundant all along.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
