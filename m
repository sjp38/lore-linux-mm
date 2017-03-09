Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38A42831FE
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 20:28:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id l66so87011204pfl.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 17:28:57 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id x126si4830596pgx.184.2017.03.08.17.28.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 17:28:56 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v6 2/9] mm, memcg: Support to charge/uncharge multiple swap entries
References: <20170308072613.17634-1-ying.huang@intel.com>
	<20170308072613.17634-3-ying.huang@intel.com>
	<1488973076.13674.5.camel@gmail.com>
Date: Thu, 09 Mar 2017 09:28:52 +0800
In-Reply-To: <1488973076.13674.5.camel@gmail.com> (Balbir Singh's message of
	"Wed, 8 Mar 2017 22:37:56 +1100")
Message-ID: <87o9xbi6gb.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

Balbir Singh <bsingharora@gmail.com> writes:

> On Wed, 2017-03-08 at 15:26 +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>>A 
>> This patch make it possible to charge or uncharge a set of continuous
>> swap entries in the swap cgroup.A A The number of swap entries is
>> specified via an added parameter.
>>A 
>> This will be used for the THP (Transparent Huge Page) swap support.
>> Where a swap cluster backing a THP may be allocated and freed as a
>> whole.A A So a set of (HPAGE_PMD_NR) continuous swap entries backing one
>> THP need to be charged or uncharged together.A A This will batch the
>> cgroup operations for the THP swap too.
>
> A quick look at the patches makes it look sane. I wonder if we would
> make sense to track THP swapout separately as well
> (from a memory.stat perspective)

The patchset is just the first step of THP swap optimization.  So the
THP will still be split after putting the THP into the swap cache.  This
makes it unnecessary to change mem_cgroup_swapout().  I am working on a
following up patchset to further delaying THP splitting after swapping
out the THP to the disk.  In that patchset, I will change
mem_cgroup_swapout() too.

Best Regards,
Huang, Ying

> Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
