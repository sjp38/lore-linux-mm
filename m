Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A11BA6B0008
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:33:35 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c4-v6so612188qtp.9
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:33:35 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p1-v6si9920686qkb.202.2018.05.24.01.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 01:33:34 -0700 (PDT)
Subject: Re: [PATCH RFCv2 1/4] ACPI: NUMA: export pxm_to_node
References: <20180523182404.11433-1-david@redhat.com>
 <20180523182404.11433-2-david@redhat.com>
 <CAJZ5v0jar8TqC5MGRPcAVZfM3LmmoSV3fT3Sgok=r6D9cDG0+w@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <5342a59c-4ca1-2cf5-a1d4-07a6d6f03587@redhat.com>
Date: Thu, 24 May 2018 10:33:32 +0200
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0jar8TqC5MGRPcAVZfM3LmmoSV3fT3Sgok=r6D9cDG0+w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On 24.05.2018 10:12, Rafael J. Wysocki wrote:
> On Wed, May 23, 2018 at 8:24 PM, David Hildenbrand <david@redhat.com> wrote:
>> Will be needed by paravirtualized memory devices.
> 
> That's a little information.
> 
> It would be good to see the entire series at least.

It's part of this series (guess you only received the cover letter and
this patch). Here a link to the patch using it:

https://lkml.org/lkml/2018/5/23/803


> 
>> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>> Cc: Len Brown <lenb@kernel.org>
>> Cc: linux-acpi@vger.kernel.org
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  drivers/acpi/numa.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
>> index 85167603b9c9..7ffee2959350 100644
>> --- a/drivers/acpi/numa.c
>> +++ b/drivers/acpi/numa.c
>> @@ -50,6 +50,7 @@ int pxm_to_node(int pxm)
>>                 return NUMA_NO_NODE;
>>         return pxm_to_node_map[pxm];
>>  }
>> +EXPORT_SYMBOL(pxm_to_node);
> 
> EXPORT_SYMBOL_GPL(), please.

Yes, will do, thanks!

> 
>>
>>  int node_to_pxm(int node)
>>  {
>> --


-- 

Thanks,

David / dhildenb
