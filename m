Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3826B0009
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 20:39:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t13so15235pgu.23
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:39:21 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id k24si37787pgn.24.2018.04.17.17.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 17:39:20 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm 10/21] mm, THP, swap: Support to count THP swapin and its fallback
References: <20180417020230.26412-1-ying.huang@intel.com>
	<20180417020230.26412-11-ying.huang@intel.com>
	<2d6c126d-eada-1791-4a31-fd0d806e3147@infradead.org>
Date: Wed, 18 Apr 2018 08:39:15 +0800
In-Reply-To: <2d6c126d-eada-1791-4a31-fd0d806e3147@infradead.org> (Randy
	Dunlap's message of "Tue, 17 Apr 2018 14:18:08 -0700")
Message-ID: <87po2xz6to.fsf@yhuang-dev.intel.com>
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
>> 2 new /proc/vmstat fields are added, "thp_swapin" and
>> "thp_swapin_fallback" to count swapin a THP from swap device as a
>> whole and fallback to normal page swapin.
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
>>  include/linux/vm_event_item.h |  2 ++
>>  mm/huge_memory.c              |  4 +++-
>>  mm/page_io.c                  | 15 ++++++++++++---
>>  mm/vmstat.c                   |  2 ++
>>  4 files changed, 19 insertions(+), 4 deletions(-)
>> 
>
> Hi,
> Please also update Documentation/vm/transhuge.rst.

Thanks for reminding!  Will do that.

Best Regards,
Huang, Ying
