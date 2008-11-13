Message-ID: <491C8A20.1070107@goop.org>
Date: Thu, 13 Nov 2008 12:12:16 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: implement remap_pfn_range with apply_to_page_range
References: <491C61B1.10005@goop.org> <20081113195341.GA8299@cmpxchg.org>
In-Reply-To: <20081113195341.GA8299@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
>> -	do {
>> -		BUG_ON(!pte_none(*pte));
>>     
>
> Dropping by intention?
>   

Hm, I couldn't really see the point.   But I didn't really want to 
introduce any functional changes with this patch, so I'll add it back.

>> 	BUG_ON(addr >= end);
>> -	pfn -= addr >> PAGE_SHIFT;
>> -	pgd = pgd_offset(mm, addr);
>> -	flush_cache_range(vma, addr, end);
>>     
>
> Was the flushing redundant?  I can't spot it reappearing anywhere.

I guess its needed for virtually indexed cache architectures; I'll add 
it back.

Thanks for reviewing.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
