Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD526B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 02:49:11 -0400 (EDT)
Received: by qgx61 with SMTP id 61so55468433qgx.3
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 23:49:11 -0700 (PDT)
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com. [209.85.192.44])
        by mx.google.com with ESMTPS id 35si11732784qgt.128.2015.09.18.23.49.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 23:49:10 -0700 (PDT)
Received: by qgt47 with SMTP id 47so55386054qgt.2
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 23:49:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hm1TfKNbhy+EncWedgZa=LifCnrbuopHyfB9LGPvSAsQ@mail.gmail.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150826012735.8851.49787.stgit@dwillia2-desk3.amr.corp.intel.com>
	<CANMBJr6xkh1Ciqb_9JF33aPapavxLLZte1BH+rQpdRpwvLO+dA@mail.gmail.com>
	<CAPcyv4hm1TfKNbhy+EncWedgZa=LifCnrbuopHyfB9LGPvSAsQ@mail.gmail.com>
Date: Fri, 18 Sep 2015 23:49:09 -0700
Message-ID: <CANMBJr7f8ZNnAmcUfDhToL=ggU+3OBbmb8DjocuOzmPnbDmkLw@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] mm: move __phys_to_pfn and __pfn_to_phys to asm/generic/memory_model.h
From: Tyler Baker <tyler.baker@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Boaz Harrosh <boaz@plexistor.com>, david <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Kevin's boot bot <khilman@kernel.org>

On 18 September 2015 at 16:59, Dan Williams <dan.j.williams@intel.com> wrote:
> On Fri, Sep 18, 2015 at 4:42 PM, Tyler Baker <tyler.baker@linaro.org> wrote:
>> Hi,
>>
>> On 25 August 2015 at 18:27, Dan Williams <dan.j.williams@intel.com> wrote:
>>> From: Christoph Hellwig <hch@lst.de>
>>>
>>> Three architectures already define these, and we'll need them genericly
>>> soon.
>>>
>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>>> ---
>>>  arch/arm/include/asm/memory.h       |    6 ------
>>>  arch/arm64/include/asm/memory.h     |    6 ------
>>>  arch/unicore32/include/asm/memory.h |    6 ------
>>>  include/asm-generic/memory_model.h  |    6 ++++++
>>>  4 files changed, 6 insertions(+), 18 deletions(-)
>>>
>>> diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
>>> index b7f6fb462ea0..98d58bb04ac5 100644
>>> --- a/arch/arm/include/asm/memory.h
>>> +++ b/arch/arm/include/asm/memory.h
>>> @@ -119,12 +119,6 @@
>>>  #endif
>>>
>>>  /*
>>> - * Convert a physical address to a Page Frame Number and back
>>> - */
>>> -#define        __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))
>>> -#define        __pfn_to_phys(pfn)      ((phys_addr_t)(pfn) << PAGE_SHIFT)
>>> -
>>> -/*
>>>   * Convert a page to/from a physical address
>>>   */
>>>  #define page_to_phys(page)     (__pfn_to_phys(page_to_pfn(page)))
>>> diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
>>> index f800d45ea226..d808bb688751 100644
>>> --- a/arch/arm64/include/asm/memory.h
>>> +++ b/arch/arm64/include/asm/memory.h
>>> @@ -81,12 +81,6 @@
>>>  #define __phys_to_virt(x)      ((unsigned long)((x) - PHYS_OFFSET + PAGE_OFFSET))
>>>
>>>  /*
>>> - * Convert a physical address to a Page Frame Number and back
>>> - */
>>> -#define        __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))
>>> -#define        __pfn_to_phys(pfn)      ((phys_addr_t)(pfn) << PAGE_SHIFT)
>>> -
>>> -/*
>>>   * Convert a page to/from a physical address
>>>   */
>>>  #define page_to_phys(page)     (__pfn_to_phys(page_to_pfn(page)))
>>> diff --git a/arch/unicore32/include/asm/memory.h b/arch/unicore32/include/asm/memory.h
>>> index debafc40200a..3bb0a29fd2d7 100644
>>> --- a/arch/unicore32/include/asm/memory.h
>>> +++ b/arch/unicore32/include/asm/memory.h
>>> @@ -61,12 +61,6 @@
>>>  #endif
>>>
>>>  /*
>>> - * Convert a physical address to a Page Frame Number and back
>>> - */
>>> -#define        __phys_to_pfn(paddr)    ((paddr) >> PAGE_SHIFT)
>>> -#define        __pfn_to_phys(pfn)      ((pfn) << PAGE_SHIFT)
>>> -
>>> -/*
>>>   * Convert a page to/from a physical address
>>>   */
>>>  #define page_to_phys(page)     (__pfn_to_phys(page_to_pfn(page)))
>>> diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/memory_model.h
>>> index 14909b0b9cae..f20f407ce45d 100644
>>> --- a/include/asm-generic/memory_model.h
>>> +++ b/include/asm-generic/memory_model.h
>>> @@ -69,6 +69,12 @@
>>>  })
>>>  #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
>>>
>>> +/*
>>> + * Convert a physical address to a Page Frame Number and back
>>> + */
>>> +#define        __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))
>>> +#define        __pfn_to_phys(pfn)      ((pfn) << PAGE_SHIFT)
>>
>> The kernelci.org bot has been reporting complete boot failures[1] on
>> ARM platforms with more than 4GB of memory and LPAE enabled. I've
>> bisected[2] the failures down to this commit, and reverting it on top
>> of the latest mainline resolves the boot issue. I took a closer look
>> at this patch and noticed the cast to phys_addr_t was dropped in the
>> generic function. Adding this to the new generic function solves the
>> boot issue I'm reporting.
>>
>> diff --git a/include/asm-generic/memory_model.h
>> b/include/asm-generic/memory_model.h
>> index f20f407..db9f5c7 100644
>> --- a/include/asm-generic/memory_model.h
>> +++ b/include/asm-generic/memory_model.h
>> @@ -73,7 +73,7 @@
>>   * Convert a physical address to a Page Frame Number and back
>>   */
>>  #define        __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))
>> -#define        __pfn_to_phys(pfn)      ((pfn) << PAGE_SHIFT)
>> +#define        __pfn_to_phys(pfn)      ((phys_addr_t)(pfn) << PAGE_SHIFT)
>>
>>  #define page_to_pfn __page_to_pfn
>>  #define pfn_to_page __pfn_to_page
>>
>> If this fix is valid, I can send a formal patch or it can be squashed
>> into the original commit.
>
> This fix is valid, but I wonder if it should just use the existing
> PFN_PHYS() definition in include/linux/pfn.h?

Good suggestion, seems like the rational thing to do. FWIW, I gave the
patch below a spin through the kernelci.org build/boot ci loop[1]. All
went well, no new regressions were detected.

From: Tyler Baker <tyler.baker@linaro.org>
Date: Fri, 18 Sep 2015 17:56:26 -0700
Subject: [PATCH] mm: fix type cast in __pfn_to_phys()

The various definitions of __pfn_to_phys() have been consolidated to
use a generic macro in include/asm-generic/memory_model.h. This hit
mainline in the form of 012dcef3f058 "mm: move __phys_to_pfn and
__pfn_to_phys to asm/generic/memory_model.h". When the generic macro
was implemented the type cast to phys_addr_t was dropped which caused
boot regressions on ARM platforms with more than 4GB of memory and
LPAE enabled.

It was suggested to use PFN_PHYS() defined in include/linux/pfn.h
as provides the correct logic and avoids further duplication.

Reported-by: kernelci.org bot <bot@kernelci.org>
Suggested-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Tyler Baker <tyler.baker@linaro.org>
---
 include/asm-generic/memory_model.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/asm-generic/memory_model.h
b/include/asm-generic/memory_model.h
index f20f407..4b4b056 100644
--- a/include/asm-generic/memory_model.h
+++ b/include/asm-generic/memory_model.h
@@ -73,7 +73,7 @@
  * Convert a physical address to a Page Frame Number and back
  */
 #define __phys_to_pfn(paddr) ((unsigned long)((paddr) >> PAGE_SHIFT))
-#define __pfn_to_phys(pfn) ((pfn) << PAGE_SHIFT)
+#define __pfn_to_phys(pfn) PFN_PHYS(pfn)

 #define page_to_pfn __page_to_pfn
 #define pfn_to_page __pfn_to_page
-- 
2.1.4

Cheers,

Tyler

[1] http://kernelci.org/boot/all/job/tbaker/kernel/v4.3-rc1-221-ge75368554bf8/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
