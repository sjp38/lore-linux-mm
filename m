Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 435F16B000A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 21:09:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u16-v6so12814418pfm.15
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 18:09:08 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id x190-v6si14440101pgb.158.2018.07.09.18.09.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 18:09:07 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 01/21] mm, THP, swap: Enable PMD swap operations for CONFIG_THP_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-2-ying.huang@intel.com>
	<11735e2e-781f-492f-7a1a-71b91e0876dc@linux.intel.com>
Date: Tue, 10 Jul 2018 09:08:42 +0800
In-Reply-To: <11735e2e-781f-492f-7a1a-71b91e0876dc@linux.intel.com> (Dave
	Hansen's message of "Mon, 9 Jul 2018 08:59:20 -0700")
Message-ID: <871scbkicl.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> On 06/21/2018 08:51 PM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> Previously, the PMD swap operations are only enabled for
>> CONFIG_ARCH_ENABLE_THP_MIGRATION.  Because they are only used by the
>> THP migration support.  We will support PMD swap mapping to the huge
>> swap cluster and swapin the THP as a whole.  That will be enabled via
>> CONFIG_THP_SWAP and needs these PMD swap operations.  So enable the
>> PMD swap operations for CONFIG_THP_SWAP too.
>
> This commit message kinda skirts around the real reasons for this patch.
>  Shouldn't we just say something like:
>
> 	Currently, "swap entries" in the page tables are used for a
> 	number of things outside of actual swap, like page migration.
> 	We support THP/PMD "swap entries" for page migration currently
> 	and the functions behind this are tied to page migration's
> 	config option (CONFIG_ARCH_ENABLE_THP_MIGRATION).
>
> 	But, we also need them for THP swap.
> 	...
>
> It would also be nice to explain a bit why you are moving code around.

This looks much better than my original words.  Thanks for help!

> Would this look any better if we made a Kconfig option:
>
> 	config HAVE_THP_SWAP_ENTRIES
> 		def_bool n
> 		# "Swap entries" in the page tables are used
> 		# both for migration and actual swap.
> 		depends on THP_SWAP || ARCH_ENABLE_THP_MIGRATION
>
> You logically talked about this need for PMD swap operations in your
> commit message, so I think it makes sense to codify that in a single
> place where it can be coherently explained.

Because both you and Dan thinks it's better to add new Kconfig option, I
will do that.

Best Regards,
Huang, Ying
