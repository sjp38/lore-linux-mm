Message-ID: <3D1F5034.9060409@shaolinmicro.com>
Date: Mon, 01 Jul 2002 02:38:44 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: Re: Big memory, no struct page allocation
References: <3D158D1E.1090802@shaolinmicro.com> <20020623085914.GN25360@holomorphy.com> <3D15E9D0.1090209@shaolinmicro.com> <20020627013833.GO25360@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

>William Lee Irwin III wrote:
>  
>
>>>Try allocating it at boot-time with the bootmem allocator.
>>>      
>>>
>
>On Sun, Jun 23, 2002 at 11:31:28PM +0800, David Chow wrote:
>  
>
>>Thanks for suggestions, you mean this will allow no struct page or can 
>>use memory more than 1GB? Please make clear on direction, I would love 
>>to know. Thanks.
>>    
>>
>
>On 32-bit machines with 3:1 process address space splits yes.
>
>In this case you're far better off playing games with the highmem
>initialization in order to slice the memory out of there and kmap it.
>
>
>Cheers,
>Bill
>  
>
In other words, even I have 2G physical memory, I cannot have benefits 
of using all memory for pagecache, this also means I cannot create any 
cache beyong a 1G size in kernel. That's a pitty for 32-bit systems, 
with himem, how does it work?

David


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
