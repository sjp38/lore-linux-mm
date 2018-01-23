Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAFFC800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:01:45 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id t12so4704336lfi.4
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:01:45 -0800 (PST)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [2a02:6b8:0:1465::fd])
        by mx.google.com with ESMTPS id v7si7010193ljc.281.2018.01.23.01.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 01:01:44 -0800 (PST)
Subject: Re: [PATCH] vmalloc: add __alloc_vm_area() for optimizing vmap stack
References: <150728974697.743944.5376694940133890044.stgit@buzz>
 <20171008091654.GA29939@infradead.org>
 <a7dd5f4e-5a63-3129-4b42-924ae2166d36@yandex-team.ru>
 <CALCETrWcZCz18UQ_A-41HOOo-9Q7SdTA=bgpr98TJh3wbDG4wA@mail.gmail.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <f468146d-2844-a269-1f4b-62a2aaab9fd1@yandex-team.ru>
Date: Tue, 23 Jan 2018 12:01:43 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrWcZCz18UQ_A-41HOOo-9Q7SdTA=bgpr98TJh3wbDG4wA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: ru-RU
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 22.01.2018 23:51, Andy Lutomirski wrote:
> On Wed, Oct 11, 2017 at 6:32 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> On 08.10.2017 12:16, Christoph Hellwig wrote:
>>>
>>> This looks fine in general, but a few comments:
>>>
>>>    - can you split adding the new function from switching over the fork
>>>      codeok
>>
>>
>>>    - at least kasan and vmalloc_user/vmalloc_32_user use very similar
>>>      patterns, can you switch them over as well?
>>
>>
>> I don't see why VM_USERMAP cannot be set right at allocation.
>>
>> I'll add vm_flags argument to __vmalloc_node() and
>> pass here VM_USERMAP from vmalloc_user/vmalloc_32_user
>> in separate patch.
>>
>> KASAN is different: it allocates shadow area for area allocated for module.
>> Pointer to module area must be pushed from module_alloc().
>> This isn't worth optimization.
>>
>>>    - the new __alloc_vm_area looks very different from alloc_vm_area,
>>>      maybe it needs a better name?  vmalloc_range_area for example?
>>
>>
>> __vmalloc_area() is vacant - this most low-level, so I'll keep "__".
>>
>>>    - when you split an existing function please keep the more low-level
>>>      function on top of the higher level one that calls it.ok
> 
> Did this ever get re-sent?
> 

It seems not. Probably lost in race-condition with my vacation.
Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
