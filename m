Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C17F26B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 15:51:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b36-v6so12785663pli.2
        for <linux-mm@kvack.org>; Tue, 22 May 2018 12:51:02 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30131.outbound.protection.outlook.com. [40.107.3.131])
        by mx.google.com with ESMTPS id t12-v6si13630345pgr.690.2018.05.22.12.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 12:51:01 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] kasan: fix memory hotplug during boot
References: <20180522100756.18478-1-david@redhat.com>
 <20180522100756.18478-3-david@redhat.com>
 <f4378c56-acc2-a5cf-724c-76cffee28235@virtuozzo.com>
 <ff21c6e7-cb32-60d8-abd3-dfc6be3d05f7@redhat.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <09c36096-f8c8-b9e9-0bed-113e494f159a@virtuozzo.com>
Date: Tue, 22 May 2018 22:50:12 +0300
MIME-Version: 1.0
In-Reply-To: <ff21c6e7-cb32-60d8-abd3-dfc6be3d05f7@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>



On 05/22/2018 07:36 PM, David Hildenbrand wrote:
> On 22.05.2018 18:26, Andrey Ryabinin wrote:
>>
>>
>> On 05/22/2018 01:07 PM, David Hildenbrand wrote:
>>> Using module_init() is wrong. E.g. ACPI adds and onlines memory before
>>> our memory notifier gets registered.
>>>
>>> This makes sure that ACPI memory detected during boot up will not
>>> result in a kernel crash.
>>>
>>> Easily reproducable with QEMU, just specify a DIMM when starting up.
>>
>>          reproducible
>>>
>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>> ---
>>
>> Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
>> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: <stable@vger.kernel.org>
> 
> Think this even dates back to:
> 
> 786a8959912e ("kasan: disable memory hotplug")
> 

Indeed.
