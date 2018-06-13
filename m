Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82AC26B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 07:49:28 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id j9-v6so664286uan.8
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 04:49:28 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z28-v6si1168520uae.194.2018.06.13.04.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 04:49:24 -0700 (PDT)
Date: Wed, 13 Jun 2018 04:49:09 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180613114909.alyfvvc5z2g2fbf7@ca-dmjordan1.us.oracle.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
 <20180523082625.6897-4-ying.huang@intel.com>
 <20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
 <87o9ggpzlk.fsf@yhuang-dev.intel.com>
 <20180612214402.cpjmcyjkkwtkgjyu@ca-dmjordan1.us.oracle.com>
 <87vaano4rl.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vaano4rl.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Wed, Jun 13, 2018 at 09:26:54AM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> 
> > On Tue, Jun 12, 2018 at 09:23:19AM +0800, Huang, Ying wrote:
> >> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> >> >> +#else
> >> >> +static inline int __swap_duplicate_cluster(swp_entry_t *entry,
> >> >
> >> > This doesn't need inline.
> >> 
> >> Why not?  This is just a one line stub.
> >
> > Forgot to respond to this.  The compiler will likely choose to optimize out
> > calls to an empty function like this.  Checking, this is indeed what it does in
> > this case on my machine, with or without inline.
> 
> Yes.  I believe a decent compiler will inline the function in any way.
> And it does no harm to keep "inline" too, Yes?

Right, it does no harm, it's just a matter of style.
