Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB8D68E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 20:52:29 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so16870037pfb.17
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:52:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s84si14572841pgs.306.2018.12.18.17.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 17:52:28 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V9 10/21] swap: Swapin a THP in one piece
References: <20181214062754.13723-1-ying.huang@intel.com>
	<20181214062754.13723-11-ying.huang@intel.com>
	<20181218205638.zsoumw2ob6fxl6ub@ca-dmjordan1.us.oracle.com>
Date: Wed, 19 Dec 2018 09:52:24 +0800
In-Reply-To: <20181218205638.zsoumw2ob6fxl6ub@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Tue, 18 Dec 2018 12:56:38 -0800")
Message-ID: <87ftuuqo4n.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Fri, Dec 14, 2018 at 02:27:43PM +0800, Huang Ying wrote:
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 1cec1eec340e..644cb5d6b056 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -33,6 +33,8 @@
>>  #include <linux/page_idle.h>
>>  #include <linux/shmem_fs.h>
>>  #include <linux/oom.h>
>> +#include <linux/delayacct.h>
>> +#include <linux/swap.h>
>
> swap.h is already #included in this file.

Will fix this, Thanks!

Best Regards,
Huang, Ying
