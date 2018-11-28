Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA1AE6B4C5D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 05:03:12 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n39so22883298qtn.18
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 02:03:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 1si4707103qvo.44.2018.11.28.02.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 02:03:11 -0800 (PST)
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz> <1543388866.2920.5.camel@suse.de>
From: David Hildenbrand <david@redhat.com>
Message-ID: <e9166b74-58ce-3896-e170-52e4aa852024@redhat.com>
Date: Wed, 28 Nov 2018 11:03:08 +0100
MIME-Version: 1.0
In-Reply-To: <1543388866.2920.5.camel@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, linux-mm@kvack.org

On 28.11.18 08:07, Oscar Salvador wrote:
> On Wed, 2018-11-28 at 07:50 +0100, Michal Hocko wrote:
>>
>> I didn't get to read through this whole series but one thing that is
>> on
>> my todo list for a long time is to remove all this stuff. I do not
>> think
>> we really want to simplify it when there shouldn't be any real reason
>> to
>> have it around at all. Why do we need to shrink zone/node at all?
>>
>> Now that we can override and assign memory to both normal na movable
>> zones I think we should be good to remove shrinking.
> 
> I feel like I am missing a piece of obvious information here.
> Right now, we shrink zone/node to decrease spanned pages.
> I thought this was done for consistency, and in case of the node, in
> try_offline_node we use the spanned pages to go through all sections
> to check whether the node can be removed or not.
> 

I am also not sure if that can be done. Anyhow, simplifying first and
getting rid later is in my opinion also good enough. One step at a time :)

> From your comment, I understand that we do not really care about
> spanned pages. Why?
> Could you please expand on that?
> 
> And if we remove it, would not this give to a user "bad"/confusing
> information when looking at /proc/zoneinfo?
> 
> 
> Thanks
> 


-- 

Thanks,

David / dhildenb
