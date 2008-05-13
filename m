Received: by wx-out-0506.google.com with SMTP id h29so2414533wxd.11
        for <linux-mm@kvack.org>; Tue, 13 May 2008 07:38:57 -0700 (PDT)
Message-ID: <4829A7FB.5070507@gmail.com>
Date: Tue, 13 May 2008 16:38:51 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/1] mm: add virt to phys debug
References: <Pine.LNX.4.64.0804281322510.31163@schroedinger.engr.sgi.com> <1209669740-10493-1-git-send-email-jirislaby@gmail.com> <Pine.LNX.4.64.0805011310390.9288@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0805011310390.9288@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Jeremy Fitzhardinge <jeremy@goop.org>, pageexec@freemail.hu, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, herbert@gondor.apana.org.au, penberg@cs.helsinki.fi, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter napsal(a):
> On Thu, 1 May 2008, Jiri Slaby wrote:
>> Add some (configurable) expensive sanity checking to catch wrong address
>> translations on x86.
>>
>> - create linux/mmdebug.h file to be able include this file in
>>   asm headers to not get unsolvable loops in header files
>> - __phys_addr on x86_32 became a function in ioremap.c since
>>   PAGE_OFFSET and is_vmalloc_addr is undefined if declared in
>>   page_32.h (again circular dependencies)
>> - add __phys_addr_const for initializing doublefault_tss.__cr3
> 
> Hmmm.. We could use include/linux/bounds.h to make 
> VMALLOC_START/VMALLOC_END (or whatever you need for checking the memory 
> boundaries) a cpp constant which may allow the use in page_32.h without 
> circular dependencies.

Hrm, not that easy. I ended up in splitting fixmap_32.h (VMALLOC constants 
depends on it on 32-bit), moving around constants from over all the tree 
(NR_CPUS, FIX_ACPI_PAGES...) to not include files which would create loops, 
but still not having e.g. PMD_MASK available on all configurations. I think 
it's not worth it. Objections to merging the patch as was 
(http://lkml.org/lkml/2008/5/1/300)?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
