Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70DB66B0008
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:41:34 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 35-v6so6618849pla.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:41:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p13si9070920pgn.267.2018.04.16.11.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 11:41:33 -0700 (PDT)
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
 <20180416174740.GA12686@bombadil.infradead.org>
 <CAPcyv4hUsADs9ueDfLKvcqHvz3Z4ziW=a1V6rkcOtTvoJhw7xg@mail.gmail.com>
 <20180416182146.GC12686@bombadil.infradead.org>
 <CAFqt6zZ9BJXjBxjJy06fOTZo8ybVYg3YOQjGbdaWK0NoAhzofg@mail.gmail.com>
 <CAPcyv4hYDADk_-52XHAWBNXqrVuef7Q9Dz9q+x4Y++mP0bxp2A@mail.gmail.com>
 <CAFqt6zarE3N4Ha5w54ez9aGPDGh4Qr5uxcAfYnUYZUnzDb26yg@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <79c1622b-71a3-a8f6-e814-3510ca0dc60e@infradead.org>
Date: Mon, 16 Apr 2018 11:41:27 -0700
MIME-Version: 1.0
In-Reply-To: <CAFqt6zarE3N4Ha5w54ez9aGPDGh4Qr5uxcAfYnUYZUnzDb26yg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On 04/16/2018 11:37 AM, Souptick Joarder wrote:
> On Tue, Apr 17, 2018 at 12:05 AM, Dan Williams <dan.j.williams@intel.com> wrote:
>> On Mon, Apr 16, 2018 at 11:28 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
>>> On Mon, Apr 16, 2018 at 11:51 PM, Matthew Wilcox <willy@infradead.org> wrote:
>>>> On Mon, Apr 16, 2018 at 11:00:26AM -0700, Dan Williams wrote:
>>>>> On Mon, Apr 16, 2018 at 10:47 AM, Matthew Wilcox <willy@infradead.org> wrote:
>>>>>> On Mon, Apr 16, 2018 at 09:14:48AM -0700, Dan Williams wrote:
>>>>>>>> -       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
>>>>>>>> -
>>>>>>>> -       if (rc == -ENOMEM)
>>>>>>>> -               return VM_FAULT_OOM;
>>>>>>>> -       if (rc < 0 && rc != -EBUSY)
>>>>>>>> -               return VM_FAULT_SIGBUS;
>>>>>>>> -
>>>>>>>> -       return VM_FAULT_NOPAGE;
>>>>>>>> +       return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
>>>>>>>
>>>>>>> Ugh, so this change to vmf_insert_mixed() went upstream without fixing
>>>>>>> the users? This changelog is now misleading as it does not mention
>>>>>>> that is now an urgent standalone fix. On first read I assumed this was
>>>>>>> part of a wider effort for 4.18.
>>>>>>
>>>>>> You read too quickly.  vmf_insert_mixed() is a *new* function which
>>>>>> *replaces* vm_insert_mixed() and
>>>>>> awful-mangling-of-return-values-done-per-driver.
>>>>>>
>>>>>> Eventually vm_insert_mixed() will be deleted.  But today is not that day.
>>>>>
>>>>> Ah, ok, thanks for the clarification. Then this patch should
>>>>> definitely be re-titled to "dax: convert to the new vmf_insert_mixed()
>>>>> helper". The vm_fault_t conversion is just a minor side-effect of that
>>>>> larger change. I assume this can wait for v4.18.
>>>
>>> The primary objective is to change the return type to
>>> vm_fault_t in all fault handlers and to support that
>>> we have replace vm_insert_mixed() with vmf_insert_
>>> mixed() within one fault handler function.
>>>
>>> Do I really need to change the patch title ?
>>
>> At this point, yes, or at least mention the vm_insert_mixed -->
>> vmf_insert_mixed conversion in the changelog.
> 
> Ok, I will add this in change log and send v2.
> 

and please try to use more columns per line of text.

E.g. from the uio: patch:

Use new return type vm_fault_t for fault handler
in struct vm_operations_struct. For now, this is
just documenting that the function returns a VM_
FAULT value rather than an errno.  Once all inst
ances are converted, vm_fault_t will become a di
stinct type


Several of those lines are chopped at odd places.

-- 
~Randy
