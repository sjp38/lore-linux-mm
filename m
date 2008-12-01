Received: by nf-out-0910.google.com with SMTP id c10so1521806nfd.6
        for <linux-mm@kvack.org>; Mon, 01 Dec 2008 09:32:45 -0800 (PST)
Message-ID: <49341FB9.80702@gmail.com>
Date: Mon, 01 Dec 2008 20:32:41 +0300
From: Alexey Starikovskiy <aystarik@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch][rfc] acpi: do not use kmem caches
References: <20081201083128.GB2529@wotan.suse.de> <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com> <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <20081201133646.GC10790@wotan.suse.de> <4933F14C.7020200@gmail.com> <20081201171806.GA14074@infradead.org>
In-Reply-To: <20081201171806.GA14074@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Mon, Dec 01, 2008 at 05:14:36PM +0300, Alexey Starikovskiy wrote:
>   
>> Why then you try to delete ACPICA code, which might be just disabled by
>> undefining ACPI_USE_LOCAL_CACHE?
>> If you do want to go that path, you need to create patch against ACPICA, not
>> Linux code.
>>     
>
> Sorry dude, but that's not how Linux development works.   Please talk to
> some intel OTC folks to get an advice on how it does.
>
>   
We are not speaking about Linux code here -- Nick changed ACPICA files.
And he already admits, that his patch is at least half-way wrong.
Sorry dude, ACPICA code is not Linux only, so one needs some care while
dropping some functionality from it.
>>> Ah OK I misread, that's the cache's freelist... ACPI shouldn't be poking
>>> this button inside the slab allocator anyway, honestly. What is it
>>> for?
>>>   
>>>       
>> And it is not actually used -- you cannot unload ACPI interpreter, and
>> this function is called only from there.
>>     
>
> Care to remove all this dead code?
>
>   
It is used at least in Windows userspace programs. So, removing these 4 
lines only from Linux will
create another headache for Len during his merging of each new ACPICA 
release into Linux.
>>> Is there a reasonable performance or memory win by using kmem cache? If
>>> not, then they should not be used
>>>       
>> ACPI is still working in machines with several megabytes of RAM and  
>> 100mhz Pentium processors. Do you say we should just not consider them  
>> any longer?
>> If so, then just delete all ACPICA caches altogether.
>>     
>
> As Nick is trying to explain you for a while it's not actually going
> to be a performance benefit for these, quite contrary because of how
> slab caches waste a lot of memory when only used very lightly or not
> at all.
>
>   
If you care to do the math, and I helped you in another posting, he may 
save about 11k in 32bit mode on thinkpad, and loose 70k in 64bit mode on 
similar thinkpad.

Regards,
Alex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
