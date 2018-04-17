Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61E4F6B000A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:12:44 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k27so16954089wre.23
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:12:44 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id o15si11787653wrh.126.2018.04.17.14.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 14:12:43 -0700 (PDT)
Subject: Re: [PATCH -mm 06/21] mm, THP, swap: Support PMD swap mapping when
 splitting huge PMD
References: <20180417020230.26412-1-ying.huang@intel.com>
 <20180417020230.26412-7-ying.huang@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7ae64b5e-79ee-5768-34a3-75e33ea45246@infradead.org>
Date: Tue, 17 Apr 2018 14:12:05 -0700
MIME-Version: 1.0
In-Reply-To: <20180417020230.26412-7-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On 04/16/18 19:02, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> A huge PMD need to be split when zap a part of the PMD mapping etc.
> If the PMD mapping is a swap mapping, we need to split it too.  This
> patch implemented the support for this.  This is similar as splitting
> the PMD page mapping, except we need to decrease the PMD swap mapping
> count for the huge swap cluster too.  If the PMD swap mapping count
> becomes 0, the huge swap cluster will be split.
> 
> Notice: is_huge_zero_pmd() and pmd_page() doesn't work well with swap
> PMD, so pmd_present() check is called before them.

FWIW, I would prefer to see that comment in the source code, not just
in the commit description.

> 
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  include/linux/swap.h |  6 +++++
>  mm/huge_memory.c     | 54 ++++++++++++++++++++++++++++++++++++++++----
>  mm/swapfile.c        | 28 +++++++++++++++++++++++
>  3 files changed, 83 insertions(+), 5 deletions(-)


-- 
~Randy
