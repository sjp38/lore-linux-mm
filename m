Message-ID: <4545325D.8080905@mbligh.org>
Date: Sun, 29 Oct 2006 14:59:41 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: Slab panic on 2.6.19-rc3-git5 (-git4 was OK)
References: <454442DC.9050703@google.com> <20061029000513.de5af713.akpm@osdl.org> <4544E92C.8000103@shadowen.org>
In-Reply-To: <4544E92C.8000103@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

>>> kernel BUG in cache_grow at mm/slab.c:2705!
>> This?
>>
>> --- a/mm/vmalloc.c~__vmalloc_area_node-fix
>> +++ a/mm/vmalloc.c
>> @@ -428,7 +428,8 @@ void *__vmalloc_area_node(struct vm_stru
>>  	area->nr_pages = nr_pages;
>>  	/* Please note that the recursion is strictly bounded. */
>>  	if (array_size > PAGE_SIZE) {
>> -		pages = __vmalloc_node(array_size, gfp_mask, PAGE_KERNEL, node);
>> +		pages = __vmalloc_node(array_size, gfp_mask & ~__GFP_HIGHMEM,
>> +					PAGE_KERNEL, node);
>>  		area->flags |= VM_VPAGES;
>>  	} else {
>>  		pages = kmalloc_node(array_size,
>> _
> 
> /me shoves it into the tests... results in a couple of hours.

Seems like that doesn't fix it, I'm afraid.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
