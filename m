Message-ID: <4906C789.7060408@goop.org>
Date: Tue, 28 Oct 2008 19:04:25 +1100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: vm_unmap_aliases and Xen
References: <49010D41.1080305@goop.org> <200810281619.10388.nickpiggin@yahoo.com.au>
In-Reply-To: <200810281619.10388.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Friday 24 October 2008 10:48, Jeremy Fitzhardinge wrote:
>   
>> I've been having a few problems with Xen, I suspect as a result of the
>> lazy unmapping in vmalloc.c.
>>
>> One immediate one is that vm_unmap_aliases() will oops if you call it
>> before vmalloc_init() is called, which can happen in the Xen case.  RFC
>> patch below.
>>     
>
> Sure, we could do that. If you add an unlikely, and a __read_mostly,
> I'd ack it. Thanks for picking this up.
>   

OK, will respin accordingly.

>> But the bigger problem I'm seeing is that despite calling
>> vm_unmap_aliases() at the pertinent places, I'm still seeing errors
>> resulting from stray aliases.  Is it possible that vm_unmap_aliases()
>> could be missing some, or not completely synchronous?
>>     
>
> It's possible, but of course that would not be by design ;)
>
> I've had another look over it, and nothing obvious comes to
> mind.
>   

I found the problem and fixed it; I was just doing the operations in the 
wrong order.

Thanks,
    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
