Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D47C6B0007
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 21:26:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n19-v6so469330pff.8
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 18:26:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id bf6-v6si1434527plb.44.2018.06.12.18.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 18:26:57 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in swap_duplicate()
References: <20180523082625.6897-1-ying.huang@intel.com>
	<20180523082625.6897-4-ying.huang@intel.com>
	<20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
	<87o9ggpzlk.fsf@yhuang-dev.intel.com>
	<20180612214402.cpjmcyjkkwtkgjyu@ca-dmjordan1.us.oracle.com>
Date: Wed, 13 Jun 2018 09:26:54 +0800
In-Reply-To: <20180612214402.cpjmcyjkkwtkgjyu@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Tue, 12 Jun 2018 14:44:02 -0700")
Message-ID: <87vaano4rl.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Tue, Jun 12, 2018 at 09:23:19AM +0800, Huang, Ying wrote:
>> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
>> >> +#else
>> >> +static inline int __swap_duplicate_cluster(swp_entry_t *entry,
>> >
>> > This doesn't need inline.
>> 
>> Why not?  This is just a one line stub.
>
> Forgot to respond to this.  The compiler will likely choose to optimize out
> calls to an empty function like this.  Checking, this is indeed what it does in
> this case on my machine, with or without inline.

Yes.  I believe a decent compiler will inline the function in any way.
And it does no harm to keep "inline" too, Yes?

> By the way, when building without CONFIG_THP_SWAP, we get
>
>   linux/mm/swapfile.c:933:13: warning: a??__swap_free_clustera?? defined but not used [-Wunused-function]
>    static void __swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
>                ^~~~~~~~~~~~~~~~~~~

Thanks!  I will fix this.  Don't know why 0-Day didn't catch this.

Best Regards,
Huang, Ying
