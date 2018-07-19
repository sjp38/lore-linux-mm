Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6636B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:39:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d10-v6so3552520pgv.8
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:39:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f3-v6si5329099pld.513.2018.07.19.05.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Jul 2018 05:39:20 -0700 (PDT)
Date: Thu, 19 Jul 2018 05:39:08 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 1/8] swap: Add comments to lock_cluster_or_swap_info()
Message-ID: <20180719123908.GA28522@infradead.org>
References: <20180719084842.11385-1-ying.huang@intel.com>
 <20180719084842.11385-2-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719084842.11385-2-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Thu, Jul 19, 2018 at 04:48:35PM +0800, Huang Ying wrote:
> +/*
> + * Determine the locking method in use for this device.  Return
> + * swap_cluster_info if SSD-style cluster-based locking is in place.
> + */
>  static inline struct swap_cluster_info *lock_cluster_or_swap_info(
>  	struct swap_info_struct *si,
>  	unsigned long offset)
>  {
>  	struct swap_cluster_info *ci;
>  
> +	/* Try to use fine-grained SSD-style locking if available: */

Once you touch this are can you also please use standard two-tab
alignment for the spill-over function arguments:

static inline struct swap_cluster_info *lock_cluster_or_swap_info(
		struct swap_info_struct *si, unsigned long offset)
