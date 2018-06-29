Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCA766B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 02:04:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b5-v6so3985532pfi.5
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 23:04:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n18-v6si4872979pgg.225.2018.06.28.23.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Jun 2018 23:04:16 -0700 (PDT)
Date: Thu, 28 Jun 2018 23:04:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH -mm -v4 03/21] mm, THP, swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180629060412.GI7646@bombadil.infradead.org>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622035151.6676-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Fri, Jun 22, 2018 at 11:51:33AM +0800, Huang, Ying wrote:
> +++ b/mm/swap_state.c
> @@ -433,7 +433,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		/*
>  		 * Swap entry may have been freed since our caller observed it.
>  		 */
> -		err = swapcache_prepare(entry);
> +		err = swapcache_prepare(entry, false);
>  		if (err == -EEXIST) {
>  			radix_tree_preload_end();
>  			/*

This commit should be just a textual conflict.
