Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE846B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 10:41:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a70-v6so16767982qkb.16
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 07:41:37 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r77-v6si1439960qke.292.2018.08.07.07.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 07:41:36 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] Do not touch pages in remove_memory path
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <6407d022-87b7-f5e0-572a-c5c29aba1314@redhat.com>
 <20180807141922.GA5244@techadventures.net>
 <d0ea36f7-9329-f947-3862-011827aee20c@redhat.com>
 <20180807142826.GB5309@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <6d07f588-cc40-132e-2d89-26e00fff5a88@redhat.com>
Date: Tue, 7 Aug 2018 16:41:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180807142826.GB5309@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 07.08.2018 16:28, Oscar Salvador wrote:
> On Tue, Aug 07, 2018 at 04:20:37PM +0200, David Hildenbrand wrote:
>> On 07.08.2018 16:19, Oscar Salvador wrote:
>>> On Tue, Aug 07, 2018 at 04:16:35PM +0200, David Hildenbrand wrote:
>>>> On 07.08.2018 15:37, osalvador@techadventures.net wrote:
>>>>> From: Oscar Salvador <osalvador@suse.de>
>>>>>
>>>>> This tries to fix [1], which was reported by David Hildenbrand, and also
>>>>> does some cleanups/refactoring.
>>>>>
>>>>> I am sending this as RFC to see if the direction I am going is right before
>>>>> spending more time into it.
>>>>> And also to gather feedback about hmm/zone_device stuff.
>>>>> The code compiles and I tested it successfully with normal memory-hotplug operations.
>>>>>
>>>>
>>>> Please coordinate next time with people already working on this,
>>>> otherwise you might end up wasting other people's time.
>>>
>>> Hi David,
>>>
>>> Sorry, if you are already working on this, I step back immediately.
>>> I will wait for your work.
>>
>> No, please keep going, you are way ahead of me ;)
>>
>> (I was got stuck at ZONE_DEVICE so far)
> 
> It seems mine breaks ZONE_DEVICE for hmm at least, so.. not much better ^^.
> So since you already got some work, let us not throw it away.

I am not close to an RFC (spent most time looking into the details -
still have plenty to learn in the MM area - and wondering on how to
handle ZONE_DEVICE). It might take some time for me to get something
clean up and running.

So let's continue with your series, I'll happily review it.

(I was just surprised by this series without a prior note as reply to
the patch where we discussed the solution for the problem)

> 
> Thanks
> 


-- 

Thanks,

David / dhildenb
