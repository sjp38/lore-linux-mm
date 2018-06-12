Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 67A466B000D
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 23:15:34 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c6-v6so13224240pll.4
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 20:15:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 65-v6si65000944pfo.229.2018.06.11.20.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 20:15:32 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in swap_duplicate()
References: <20180523082625.6897-1-ying.huang@intel.com>
	<20180523082625.6897-4-ying.huang@intel.com>
	<20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
	<87o9ggpzlk.fsf@yhuang-dev.intel.com>
Date: Tue, 12 Jun 2018 11:15:28 +0800
In-Reply-To: <87o9ggpzlk.fsf@yhuang-dev.intel.com> (Ying Huang's message of
	"Tue, 12 Jun 2018 09:23:19 +0800")
Message-ID: <87k1r4puen.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

"Huang, Ying" <ying.huang@intel.com> writes:
>> On Wed, May 23, 2018 at 04:26:07PM +0800, Huang, Ying wrote:
>>> @@ -3516,11 +3512,39 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>>
>> Two comments about this part of __swap_duplicate as long as you're moving it to
>> another function:
>>
>>    } else if (count || has_cache) {
>>    
>>    	if ((count & ~COUNT_CONTINUED) < SWAP_MAP_MAX)          /* #1   */
>>    		count += usage;
>>    	else if ((count & ~COUNT_CONTINUED) > SWAP_MAP_MAX)     /* #2   */
>>    		err = -EINVAL;
>>
>> #1:  __swap_duplicate_locked might use
>>
>>     VM_BUG_ON(usage != SWAP_HAS_CACHE && usage != 1);
>>
>> to document the unstated assumption that usage is 1 (otherwise count could
>> overflow).
>
> Sounds good.  Will do this.

Found usage parameter of __swap_duplicate() could be SWAP_MAP_SHMEM too.
We can improve the parameter checking.  But that appears not belong to
this series.

Best Regards,
Huang, Ying
