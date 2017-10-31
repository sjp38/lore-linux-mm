Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70B066B025E
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:45:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n14so15200247pfh.15
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:45:29 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTPS id f10si1869575pgr.806.2017.10.31.09.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 09:45:28 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: extract common code for calculating total memory
 size
From: "Yang Shi" <yang.s@alibaba-inc.com>
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
 <1508971740-118317-2-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.20.1710270459580.8922@nuc-kabylake>
 <180e8cff-b0e9-bed7-2283-3a96d97fdf62@alibaba-inc.com>
Message-ID: <038f781e-e96b-f122-2455-8a41d3a981a7@alibaba-inc.com>
Date: Wed, 01 Nov 2017 00:45:03 +0800
MIME-Version: 1.0
In-Reply-To: <180e8cff-b0e9-bed7-2283-3a96d97fdf62@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/27/17 9:51 AM, Yang Shi wrote:
> 
> 
> On 10/27/17 3:00 AM, Christopher Lameter wrote:
>> On Thu, 26 Oct 2017, Yang Shi wrote:
>>
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index 935c4d4..e21b81e 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -2050,6 +2050,31 @@ extern int __meminit 
>>> __early_pfn_to_nid(unsigned long pfn,
>>>   static inline void zero_resv_unavail(void) {}
>>>   #endif
>>>
>>> +static inline void calc_mem_size(unsigned long *total, unsigned long 
>>> *reserved,
>>> +                 unsigned long *highmem)
>>> +{
>>
>> Huge incline function. This needs to go into mm/page_alloc.c or
>> mm/slab_common.c
> 
> It is used by lib/show_mem.c too. But since it is definitely on a hot 
> patch, I think I can change it to non inline.

I mean it is *not* on the hot path. Sorry for the typo and inconvenience.

Yang

> 
> Thanks,
> Yang
> 
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
