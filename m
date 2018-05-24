Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EADAB6B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 05:04:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b62-v6so682499qkj.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 02:04:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c24-v6si9735616qtg.360.2018.05.24.02.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 02:04:45 -0700 (PDT)
Subject: Re: [PATCH RFCv2 1/4] ACPI: NUMA: export pxm_to_node
References: <20180523182404.11433-1-david@redhat.com>
 <20180523182404.11433-2-david@redhat.com>
 <CAJZ5v0jar8TqC5MGRPcAVZfM3LmmoSV3fT3Sgok=r6D9cDG0+w@mail.gmail.com>
 <5342a59c-4ca1-2cf5-a1d4-07a6d6f03587@redhat.com>
 <CAJZ5v0grgYRi24oyFP0xcjip5Z5apLE5ozn8znahdtkqKvD_MA@mail.gmail.com>
 <9cf4c5f3-f1ee-67c2-967e-07aa568685c4@redhat.com>
 <CAJZ5v0ionYbXse8++6c80FXajVKYLSYD7hC5RntygKJ9+PQpYg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <173eaf59-0f48-c1d0-2317-840dcb932ba7@redhat.com>
Date: Thu, 24 May 2018 11:04:43 +0200
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0ionYbXse8++6c80FXajVKYLSYD7hC5RntygKJ9+PQpYg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On 24.05.2018 11:01, Rafael J. Wysocki wrote:
> On Thu, May 24, 2018 at 10:54 AM, David Hildenbrand <david@redhat.com> wrote:
>> On 24.05.2018 10:47, Rafael J. Wysocki wrote:
>>> On Thu, May 24, 2018 at 10:33 AM, David Hildenbrand <david@redhat.com> wrote:
>>>> On 24.05.2018 10:12, Rafael J. Wysocki wrote:
>>>>> On Wed, May 23, 2018 at 8:24 PM, David Hildenbrand <david@redhat.com> wrote:
>>>>>> Will be needed by paravirtualized memory devices.
>>>>>
>>>>> That's a little information.
>>>>>
>>>>> It would be good to see the entire series at least.
>>>>
>>>> It's part of this series (guess you only received the cover letter and
>>>> this patch). Here a link to the patch using it:
>>>>
>>>> https://lkml.org/lkml/2018/5/23/803
>>>
>>> OK, thanks!
>>>
>>> It looks like you have a reason to use it in there, but please note
>>> that CONFIG_ACPI_NUMA depends on CONFIG_NUMA, so you don't need to use
>>> the latter directly in the #ifdef.  Also wouldn't IS_ENABLED() work
>>> there?
>>
>> Thanks for the tip on CONFIG_ACPI_NUMA. Wouldn't IS_ENABLED() require to
>> have a dummy implementation of pxm_to_node() in case drivers/acpi/numa.c
>> is not compiled?
> 
> Yes, it would.
> 
> But since you want export it, you can very well add one, can't you?
> I'd even say that it would be prudent to do so.
> 

Sure, can do that :)

-- 

Thanks,

David / dhildenb
