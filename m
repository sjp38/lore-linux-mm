Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB9D6B039B
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 16:22:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y90so24674740wrb.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:22:31 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id i132si146794wmg.126.2017.03.09.13.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 13:22:29 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id t189so65948008wmt.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:22:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87o9xbi6gb.fsf@yhuang-dev.intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com> <20170308072613.17634-3-ying.huang@intel.com>
 <1488973076.13674.5.camel@gmail.com> <87o9xbi6gb.fsf@yhuang-dev.intel.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 10 Mar 2017 08:22:28 +1100
Message-ID: <CAKTCnzneq1JZnSQnxNBJCxJEfk65N8GPL=K6T8Lg44t7hjtV1A@mail.gmail.com>
Subject: Re: [PATCH -mm -v6 2/9] mm, memcg: Support to charge/uncharge
 multiple swap entries
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>

On Thu, Mar 9, 2017 at 12:28 PM, Huang, Ying <ying.huang@intel.com> wrote:
> Balbir Singh <bsingharora@gmail.com> writes:
>
>> On Wed, 2017-03-08 at 15:26 +0800, Huang, Ying wrote:
>>> From: Huang Ying <ying.huang@intel.com>
>>>
>>> This patch make it possible to charge or uncharge a set of continuous
>>> swap entries in the swap cgroup.  The number of swap entries is
>>> specified via an added parameter.
>>>
>>> This will be used for the THP (Transparent Huge Page) swap support.
>>> Where a swap cluster backing a THP may be allocated and freed as a
>>> whole.  So a set of (HPAGE_PMD_NR) continuous swap entries backing one
>>> THP need to be charged or uncharged together.  This will batch the
>>> cgroup operations for the THP swap too.
>>
>> A quick look at the patches makes it look sane. I wonder if we would
>> make sense to track THP swapout separately as well
>> (from a memory.stat perspective)
>
> The patchset is just the first step of THP swap optimization.  So the
> THP will still be split after putting the THP into the swap cache.  This
> makes it unnecessary to change mem_cgroup_swapout().  I am working on a
> following up patchset to further delaying THP splitting after swapping
> out the THP to the disk.  In that patchset, I will change
> mem_cgroup_swapout() too.


Fair enough

Thanks,
Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
