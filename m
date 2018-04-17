Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFDF36B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:18:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j3so18240456ioe.13
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:18:25 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c10-v6si8546236itc.39.2018.04.17.14.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 14:18:24 -0700 (PDT)
Subject: Re: [PATCH -mm 10/21] mm, THP, swap: Support to count THP swapin and
 its fallback
References: <20180417020230.26412-1-ying.huang@intel.com>
 <20180417020230.26412-11-ying.huang@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <2d6c126d-eada-1791-4a31-fd0d806e3147@infradead.org>
Date: Tue, 17 Apr 2018 14:18:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180417020230.26412-11-ying.huang@intel.com>
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
> 2 new /proc/vmstat fields are added, "thp_swapin" and
> "thp_swapin_fallback" to count swapin a THP from swap device as a
> whole and fallback to normal page swapin.
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
>  include/linux/vm_event_item.h |  2 ++
>  mm/huge_memory.c              |  4 +++-
>  mm/page_io.c                  | 15 ++++++++++++---
>  mm/vmstat.c                   |  2 ++
>  4 files changed, 19 insertions(+), 4 deletions(-)
> 

Hi,
Please also update Documentation/vm/transhuge.rst.

Thanks.

-- 
~Randy
