Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF766B000A
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 13:25:56 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id t3-v6so3591867ywg.18
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 10:25:56 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i205-v6si3333388ywe.259.2018.10.24.10.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 10:25:55 -0700 (PDT)
Date: Wed, 24 Oct 2018 10:25:49 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V6 06/21] swap: Support PMD swap mapping when splitting
 huge PMD
Message-ID: <20181024172549.xyevip5kclq2ig33@ca-dmjordan1.us.oracle.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
 <20181010071924.18767-7-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010071924.18767-7-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Wed, Oct 10, 2018 at 03:19:09PM +0800, Huang Ying wrote:
> +#ifdef CONFIG_THP_SWAP
> +/*
> + * The corresponding page table shouldn't be changed under us, that
> + * is, the page table lock should be held.
> + */
> +int split_swap_cluster_map(swp_entry_t entry)
> +{
> +	struct swap_info_struct *si;
> +	struct swap_cluster_info *ci;
> +	unsigned long offset = swp_offset(entry);
> +
> +	VM_BUG_ON(!IS_ALIGNED(offset, SWAPFILE_CLUSTER));
> +	si = _swap_info_get(entry);
> +	if (!si)
> +		return -EBUSY;

I think this return value doesn't get used anywhere?
