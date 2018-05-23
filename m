Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 007F46B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:58:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x23-v6so12815463pfm.7
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:58:21 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20114.outbound.protection.outlook.com. [40.107.2.114])
        by mx.google.com with ESMTPS id u15-v6si19175129pfk.82.2018.05.23.02.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 May 2018 02:58:20 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] kasan: fix memory hotplug during boot
References: <20180522100756.18478-1-david@redhat.com>
 <20180522100756.18478-3-david@redhat.com>
 <f4378c56-acc2-a5cf-724c-76cffee28235@virtuozzo.com>
 <ff21c6e7-cb32-60d8-abd3-dfc6be3d05f7@redhat.com>
 <09c36096-f8c8-b9e9-0bed-113e494f159a@virtuozzo.com>
 <20180522140735.71dcd92e7b013629a7f15f91@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6642e0d8-671c-1c1e-3ae8-99ac34c3b667@virtuozzo.com>
Date: Wed, 23 May 2018 12:59:32 +0300
MIME-Version: 1.0
In-Reply-To: <20180522140735.71dcd92e7b013629a7f15f91@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>



On 05/23/2018 12:07 AM, Andrew Morton wrote:
> On Tue, 22 May 2018 22:50:12 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
>>
>>
>> On 05/22/2018 07:36 PM, David Hildenbrand wrote:
>>> On 22.05.2018 18:26, Andrey Ryabinin wrote:
>>>>
>>>>
>>>> On 05/22/2018 01:07 PM, David Hildenbrand wrote:
>>>>> Using module_init() is wrong. E.g. ACPI adds and onlines memory before
>>>>> our memory notifier gets registered.
>>>>>
>>>>> This makes sure that ACPI memory detected during boot up will not
>>>>> result in a kernel crash.
>>>>>
>>>>> Easily reproducable with QEMU, just specify a DIMM when starting up.
>>>>
>>>>          reproducible
>>>>>
>>>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>>>> ---
>>>>
>>>> Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
>>>> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>>> Cc: <stable@vger.kernel.org>
>>>
>>> Think this even dates back to:
>>>
>>> 786a8959912e ("kasan: disable memory hotplug")
>>>
>>
>> Indeed.
> 
> Is a backport to -stable justified for either of these patches?
> 

I don't see any reasons to not backport these.
The first one fixes failure to online memory, why it shouldn't be fixed in -stable?
The second one is fixes boot crash, it's definitely stable material IMO.
