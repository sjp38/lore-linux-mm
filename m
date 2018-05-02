Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 836EE6B0009
	for <linux-mm@kvack.org>; Tue,  1 May 2018 20:05:18 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f133-v6so4098841lfg.18
        for <linux-mm@kvack.org>; Tue, 01 May 2018 17:05:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s29-v6sor2030330lfk.33.2018.05.01.17.05.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 May 2018 17:05:16 -0700 (PDT)
Subject: Re: [PATCH 0/2] mm: tweaks for improving use of vmap_area
References: <20180426234243.22267-1-igor.stoppa@huawei.com>
 <20180430161515.118e6538e4d4f1cc4ae425cc@linux-foundation.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <d9f91dc9-958c-e3ec-3ca4-ecb0ddfd58f3@gmail.com>
Date: Wed, 2 May 2018 04:05:14 +0400
MIME-Version: 1.0
In-Reply-To: <20180430161515.118e6538e4d4f1cc4ae425cc@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com


On 01/05/18 03:15, Andrew Morton wrote:
> On Fri, 27 Apr 2018 03:42:41 +0400 Igor Stoppa <igor.stoppa@gmail.com> wrote:
> 
>> These two patches were written in preparation for the creation of
>> protectable memory, however their use is not limited to pmalloc and can
>> improve the use of virtually contiguous memory.
>>
>> The first provides a faster path from struct page to the vm_struct that
>> tracks it.
>>
>> The second patch renames a single linked list field inside of vmap_area.
>> The list is currently used only for disposing of the data structure, once
>> it is not in use anymore.
>> Which means that it cold be used for other purposes while it's not queued
>> for destruction.
> 
> The patches look benign to me (feel free to add my ack),

thank you

> but I'm not seeing a reason to apply them at this time?

I thought they might come useful to others playing with vmap_areas, I'll 
resubmit them anyway with the protected memory set.

But I was also hoping to get some more review, especially for the 
second, which had not received any definitive ACK/NACK, till now.

So, I'm also ok if they can be merged once the others are ACK'ed.

--
igor
