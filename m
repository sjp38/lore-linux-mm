Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD9BA6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:06:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a16-v6so21398605qkb.7
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 05:06:02 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id n8-v6si13638qvf.50.2018.06.12.05.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 05:06:02 -0700 (PDT)
Date: Tue, 12 Jun 2018 05:05:47 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180612120547.njpz73dymeru5mzy@ca-dmjordan1.us.oracle.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
 <20180523082625.6897-4-ying.huang@intel.com>
 <20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
 <87o9ggpzlk.fsf@yhuang-dev.intel.com>
 <87k1r4puen.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k1r4puen.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue, Jun 12, 2018 at 11:15:28AM +0800, Huang, Ying wrote:
> "Huang, Ying" <ying.huang@intel.com> writes:
> >> On Wed, May 23, 2018 at 04:26:07PM +0800, Huang, Ying wrote:
> >>> @@ -3516,11 +3512,39 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
> >>
> >> Two comments about this part of __swap_duplicate as long as you're moving it to
> >> another function:
> >>
> >>    } else if (count || has_cache) {
> >>    
> >>    	if ((count & ~COUNT_CONTINUED) < SWAP_MAP_MAX)          /* #1   */
> >>    		count += usage;
> >>    	else if ((count & ~COUNT_CONTINUED) > SWAP_MAP_MAX)     /* #2   */
> >>    		err = -EINVAL;
> >>
> >> #1:  __swap_duplicate_locked might use
> >>
> >>     VM_BUG_ON(usage != SWAP_HAS_CACHE && usage != 1);
> >>
> >> to document the unstated assumption that usage is 1 (otherwise count could
> >> overflow).
> >
> > Sounds good.  Will do this.
> 
> Found usage parameter of __swap_duplicate() could be SWAP_MAP_SHMEM too.
> We can improve the parameter checking.  But that appears not belong to
> this series.

Fair enough, I'll see about adding this along with the other patch I'm sending.

Daniel
