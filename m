Received: by fg-out-1718.google.com with SMTP id 19so126853fgg.4
        for <linux-mm@kvack.org>; Wed, 18 Jun 2008 06:41:54 -0700 (PDT)
Message-ID: <485910A0.1060007@gmail.com>
Date: Wed, 18 Jun 2008 15:41:52 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] MM: virtual address debug
References: <1213271800-1556-1-git-send-email-jirislaby@gmail.com> <200806182251.02486.nickpiggin@yahoo.com.au>
In-Reply-To: <200806182251.02486.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@redhat.com>, tglx@linutronix.de, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin napsal(a):
> On Thursday 12 June 2008 21:56, Jiri Slaby wrote:
>> Add some (configurable) expensive sanity checking to catch wrong address
>> translations on x86.
>>
>> - create linux/mmdebug.h file to be able include this file in
>>   asm headers to not get unsolvable loops in header files
>> - __phys_addr on x86_32 became a function in ioremap.c since
>>   PAGE_OFFSET, is_vmalloc_addr and VMALLOC_* non-constasts are undefined
>>   if declared in page_32.h
> 
> Uh, I have to disagree with this. __phys_addr is used in some really
> performance critical parts of the kernel, and the function calls are
> free mindset is just wrong. Even for modern x86 CPUs, the function
> call return might take 10 cycles or more when you include all costs.
> 
> And for something like this
> 
> #define __phys_addr(x)         ((x) - PAGE_OFFSET)
> 
> the code to call the function is probably bigger than inline generated
> code anyway.

Thanks for comments, well, are you OK with __phys_addr being a function only 
on CONFIG_VIRTUAL_DEBUG?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
