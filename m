Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 029026B026B
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 06:09:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j9-v6so15124864qtn.22
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 03:09:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t40-v6si9569881qtj.158.2018.08.14.03.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 03:09:18 -0700 (PDT)
Subject: Re: [PATCH v2 2/3] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-3-osalvador@techadventures.net>
 <82148bc6-672d-6610-757f-d910a17d23c6@redhat.com>
 <20180814093652.GA6878@techadventures.net>
 <39454952-f8c9-4ded-acb5-02192e889de0@redhat.com>
 <20180814100644.GB6979@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <292e9b31-b043-d140-77da-03082025fa1b@redhat.com>
Date: Tue, 14 Aug 2018 12:09:14 +0200
MIME-Version: 1.0
In-Reply-To: <20180814100644.GB6979@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 14.08.2018 12:06, Oscar Salvador wrote:
> On Tue, Aug 14, 2018 at 11:44:50AM +0200, David Hildenbrand wrote:
>>
>> Yes I know, as I said, if it would be local to a file I would not care.
>> Making this functions never return an error is nice, though (and as you
>> noted, the return value is never checked).
>>
>> I am a friend of stating which conditions a function expects to hold if
>> a function can be called from other parts of the system. Usually I
>> prefer to use BUG_ONs for that (whoever decides to call it can directly
>> see what he as to check before calling) or comments. But comments tend
>> to become obsolete.
> 
> Uhm, I think a BUG_ON is too much here.
> We could replace the check with a WARN_ON, just in case
> a new function decides to call unregister_mem_sect_under_nodes() in the future.
> 
> Something like:
> 
> WARN_ON(!mem_blk)
> 	return;
> 
> In that case, we should get a nice splat in the logs that should tell us
> who is calling it with an invalid mem_blk.
> 

Whatever you think is best. I have no idea what the general rules in MM
code are. Maybe dropping this check is totally fine.

-- 

Thanks,

David / dhildenb
