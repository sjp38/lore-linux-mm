Message-ID: <491D0B2F.7050900@goop.org>
Date: Thu, 13 Nov 2008 21:22:55 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: implement remap_pfn_range with apply_to_page_range
References: <491C61B1.10005@goop.org> <200811141319.56713.nickpiggin@yahoo.com.au> <491CE8C6.4060000@goop.org> <200811141417.35724.nickpiggin@yahoo.com.au>
In-Reply-To: <200811141417.35724.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Friday 14 November 2008 13:56, Jeremy Fitzhardinge wrote:
>   
>> Nick Piggin wrote:
>>     
>>> This isn't performance critical to anyone?
>>>       
>> The only difference should be between having the specialized code and an
>> indirect function call, no?
>>     
>
> Indirect function call per pte. It's going to be slower surely.
>   

Yes, though changing the calling convention to handle (up to) a whole 
page worth of ptes in one call would be fairly simple I think.

> It is accepted practice to (carefully) duplicate the page table walking
> functions in memory management code. I don't think that's a problem,
> there is already so many instances of them (just be sure to stick to
> exactly the same form and variable names, and any update or bugfix to
> any of them is trivially applicable to all).
>   

I think that's pretty awful practice, frankly, and I'd much prefer there 
to be a single iterator function which everyone uses.  The open-coded 
iterators everywhere just makes it completely impractical to even think 
about other kinds of pagetable structures.  (Of course we have at least 
two "general purpose" pagetable walkers now...)

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
