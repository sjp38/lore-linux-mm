Message-ID: <3D15E9D0.1090209@shaolinmicro.com>
Date: Sun, 23 Jun 2002 23:31:28 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: Re: Big memory, no struct page allocation
References: <3D158D1E.1090802@shaolinmicro.com> <20020623085914.GN25360@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

>On Sun, Jun 23, 2002 at 04:55:58PM +0800, David Chow wrote:
>  
>
>>Hi, I've got a silly but serious question. I want to allocate a large 
>>buffer (>512MB) in kernel. Normally you use __get_free_page and handle 
>>it with page pointers. But when get to very large (say 1024MB), I will 
>>need to use 2 level of page pointer indirection to carry the page 
>>pointer array. I also find the total size of page struct is quite large 
>>when using lots of pages, what I want is to use memory pages without 
>>struct page, is this possible? By the way, can I use lots of memory in 
>>the kernel, something like 1GB of memory allocation when physically RAM 
>>available? Please give advise. Thanks.
>>    
>>
>
>Try allocating it at boot-time with the bootmem allocator.
>
>
>Cheers,
>Bill
>  
>
Thanks for suggestions, you mean this will allow no struct page or can 
use memory more than 1GB? Please make clear on direction, I would love 
to know. Thanks.

regards,
David


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
