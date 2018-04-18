Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85D336B0006
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 20:38:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t13so14411pgu.23
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:38:31 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id j188si9774pgc.584.2018.04.17.17.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 17:38:21 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm 06/21] mm, THP, swap: Support PMD swap mapping when splitting huge PMD
References: <20180417020230.26412-1-ying.huang@intel.com>
	<20180417020230.26412-7-ying.huang@intel.com>
	<7ae64b5e-79ee-5768-34a3-75e33ea45246@infradead.org>
Date: Wed, 18 Apr 2018 08:38:16 +0800
In-Reply-To: <7ae64b5e-79ee-5768-34a3-75e33ea45246@infradead.org> (Randy
	Dunlap's message of "Tue, 17 Apr 2018 14:12:05 -0700")
Message-ID: <87tvs9z6vb.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Randy Dunlap <rdunlap@infradead.org> writes:

> On 04/16/18 19:02, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> A huge PMD need to be split when zap a part of the PMD mapping etc.
>> If the PMD mapping is a swap mapping, we need to split it too.  This
>> patch implemented the support for this.  This is similar as splitting
>> the PMD page mapping, except we need to decrease the PMD swap mapping
>> count for the huge swap cluster too.  If the PMD swap mapping count
>> becomes 0, the huge swap cluster will be split.
>> 
>> Notice: is_huge_zero_pmd() and pmd_page() doesn't work well with swap
>> PMD, so pmd_present() check is called before them.
>
> FWIW, I would prefer to see that comment in the source code, not just
> in the commit description.

Sure.  I will add comment in source code too.

Best Regards,
Huang, Ying

>> 
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  include/linux/swap.h |  6 +++++
>>  mm/huge_memory.c     | 54 ++++++++++++++++++++++++++++++++++++++++----
>>  mm/swapfile.c        | 28 +++++++++++++++++++++++
>>  3 files changed, 83 insertions(+), 5 deletions(-)
