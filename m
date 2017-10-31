Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DDA796B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:48:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l24so17318270pgu.17
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:48:08 -0700 (PDT)
Received: from out0-224.mail.aliyun.com (out0-224.mail.aliyun.com. [140.205.0.224])
        by mx.google.com with ESMTPS id j5si2010538plt.142.2017.10.31.09.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 09:48:07 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: oom: dump single excessive slab cache when oom
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
 <1508971740-118317-3-git-send-email-yang.s@alibaba-inc.com>
 <20171026145312.6svuzriij33vzgw7@dhcp22.suse.cz>
 <44577b73-2e2d-5571-4c8b-3233e3776a52@alibaba-inc.com>
 <20171026162701.re4lclnqkngczpcl@dhcp22.suse.cz>
 <20171026171414.mwetwu43hnxavwfn@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <43776378-91f8-45f3-c5af-b1db00d0c6ce@alibaba-inc.com>
Date: Wed, 01 Nov 2017 00:47:56 +0800
MIME-Version: 1.0
In-Reply-To: <20171026171414.mwetwu43hnxavwfn@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/26/17 10:14 AM, Michal Hocko wrote:
> On Thu 26-10-17 18:27:01, Michal Hocko wrote:
>> On Fri 27-10-17 00:15:17, Yang Shi wrote:
>>>
>>>
>>> On 10/26/17 7:53 AM, Michal Hocko wrote:
>>>> On Thu 26-10-17 06:49:00, Yang Shi wrote:
>>>>> Per the discussion with David [1], it looks more reasonable to just dump
>>>>
>>>> Please try to avoid external references in the changelog as much as
>>>> possible.
>>>
>>> OK.
>>>
>>>>
>>>>> the single excessive slab cache instead of dumping all slab caches when
>>>>> oom.
>>>>
>>>> You meant to say
>>>> "to just dump all slab caches which excess 10% of the total memory."
>>>>
>>>> While we are at it. Abusing calc_mem_size seems to be rather clumsy and
>>>> tt is not nodemask aware so you the whole thing is dubious for NUMA
>>>> constrained OOMs.
>>>
>>> Since we just need the total memory size of the node for NUMA constrained
>>> OOM, we should be able to use show_mem_node_skip() to bring in nodemask.
>>
>> yes
> 
> to be more specific. This would work for the total number of pages
> calculation. This is still not enough, though. You would also have to
> filter slabs per numa node and this is getting more and more complicated
> for a marginal improvement.

Yes, it sounds so. Basically, I agree with you to wait for a while to 
see how the current implementation is doing.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
