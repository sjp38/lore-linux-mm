Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1B146B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 17:44:22 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a15-v6so242088wrr.23
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 14:44:22 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t22-v6si1326815edi.195.2018.06.12.14.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 14:44:21 -0700 (PDT)
Date: Tue, 12 Jun 2018 14:44:02 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V3 03/21] mm, THP, swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180612214402.cpjmcyjkkwtkgjyu@ca-dmjordan1.us.oracle.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
 <20180523082625.6897-4-ying.huang@intel.com>
 <20180611204231.ojhlyrbmda6pouxb@ca-dmjordan1.us.oracle.com>
 <87o9ggpzlk.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87o9ggpzlk.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue, Jun 12, 2018 at 09:23:19AM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> >> +#else
> >> +static inline int __swap_duplicate_cluster(swp_entry_t *entry,
> >
> > This doesn't need inline.
> 
> Why not?  This is just a one line stub.

Forgot to respond to this.  The compiler will likely choose to optimize out
calls to an empty function like this.  Checking, this is indeed what it does in
this case on my machine, with or without inline.


By the way, when building without CONFIG_THP_SWAP, we get

  linux/mm/swapfile.c:933:13: warning: a??__swap_free_clustera?? defined but not used [-Wunused-function]
   static void __swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
               ^~~~~~~~~~~~~~~~~~~
