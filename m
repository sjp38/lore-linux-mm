Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0DB68E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:56:39 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id i15-v6so10401156ybp.7
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:56:39 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b3si9697868ybc.102.2018.12.18.12.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 12:56:39 -0800 (PST)
Date: Tue, 18 Dec 2018 12:56:38 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V9 10/21] swap: Swapin a THP in one piece
Message-ID: <20181218205638.zsoumw2ob6fxl6ub@ca-dmjordan1.us.oracle.com>
References: <20181214062754.13723-1-ying.huang@intel.com>
 <20181214062754.13723-11-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214062754.13723-11-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Fri, Dec 14, 2018 at 02:27:43PM +0800, Huang Ying wrote:
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1cec1eec340e..644cb5d6b056 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -33,6 +33,8 @@
>  #include <linux/page_idle.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/oom.h>
> +#include <linux/delayacct.h>
> +#include <linux/swap.h>

swap.h is already #included in this file.
