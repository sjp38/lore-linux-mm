Message-ID: <3D232368.5000405@shaolinmicro.com>
Date: Thu, 04 Jul 2002 00:16:40 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: Re: Big memory, no struct page allocation
References: <3D1F5034.9060409@shaolinmicro.com> <Pine.LNX.4.44L.0207011447190.25136-100000@imladris.surriel.com> <20020702060611.GT25360@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

>On Mon, 1 Jul 2002, David Chow wrote:
>  
>
>>>In other words, even I have 2G physical memory, I cannot have benefits
>>>of using all memory for pagecache, this also means I cannot create any
>>>cache beyong a 1G size in kernel. That's a pitty for 32-bit systems,
>>>with himem, how does it work?
>>>      
>>>
>
>On Mon, Jul 01, 2002 at 02:48:00PM -0300, Rik van Riel wrote:
>  
>
>>Pagecache can use highmem just fine.
>>regards,
>>Rik
>>    
>>
>
>Yes, pagecache doesn't care where it is, it just works with the
>struct pages for the memory. Things that are more internal like
>dcache and buffer cache need to be allocated from ZONE_NORMAL,
>as the kernel actually touches that memory directly.
>
>
>Cheers,
>Bill
>  
>
Thanks for advice, that means allocation of slab cache never gets over 
1G? Since you mention dcache, where dcache uses kmem_cache_create() 
calls, or it depends on the flags pass to kmem_cache_create()? What 
about kmalloc()?

Since before access a page, we have to do kmap(page), how does this 
pointer address work? I found that if my machine have less than physical 
1G RAM (actually somewhere between 900-940M), I don't have to call 
kmap() before really accessing the page data, if more than this amount 
of memory, it will result an oops. It seems for system that has more 
than 900M memory, kernel handle page data differently (need to use kmap 
before accessing the page data). Is it true that kmap only translate the 
page into a virtual address if more than 1G RAM or leave it physical is 
less than 1G RAM? I am a bit confuse in this behaviour of kmap().

regards,
David


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
