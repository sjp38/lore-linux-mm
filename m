Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C39C66B000E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:40:15 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d10-v6so4460851pll.22
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:40:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r3-v6si5838630pgg.201.2018.07.19.05.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Jul 2018 05:40:14 -0700 (PDT)
Date: Thu, 19 Jul 2018 05:40:13 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 4/8] swap: Unify normal/huge code path in
 swap_page_trans_huge_swapped()
Message-ID: <20180719124013.GB28522@infradead.org>
References: <20180719084842.11385-1-ying.huang@intel.com>
 <20180719084842.11385-5-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719084842.11385-5-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

>  static inline bool cluster_is_huge(struct swap_cluster_info *info)
>  {
> -	return info->flags & CLUSTER_FLAG_HUGE;
> +	if (IS_ENABLED(CONFIG_THP_SWAP))
> +		return info->flags & CLUSTER_FLAG_HUGE;
> +	else
> +		return false;

Nitpick: no need for an else after a return:

	if (IS_ENABLED(CONFIG_THP_SWAP))
		return info->flags & CLUSTER_FLAG_HUGE;
	return false;
