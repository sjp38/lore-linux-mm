Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D98C6B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 06:48:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a20-v6so20509691pfi.1
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 03:48:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 77-v6si25674418pfh.332.2018.07.13.03.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 03:48:30 -0700 (PDT)
Subject: Re: [PATCH 1/6] swap: Add comments to lock_cluster_or_swap_info()
References: <20180712233636.20629-1-ying.huang@intel.com>
 <20180712233636.20629-2-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <3c3a4dce-980d-0405-d269-1da9e62b1344@linux.intel.com>
Date: Fri, 13 Jul 2018 03:48:28 -0700
MIME-Version: 1.0
In-Reply-To: <20180712233636.20629-2-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

> +/*
> + * At most times, fine grained cluster lock is sufficient to protect

Can we call out those times, please?

> + * the operations on sis->swap_map.  

Please be careful with the naming.  You can call it 'si' because that's
what the function argument is named.  Or, swap_info_struct because
that's the struct name.  Calling it 'sis' is a bit sloppy, no?

> 					No need to acquire gross grained

"coarse" is a conventional antonym for "fine".

> + * sis->lock.  But cluster and cluster lock isn't available for HDD,
> + * so sis->lock will be instead for them.
> + */
>  static inline struct swap_cluster_info *lock_cluster_or_swap_info(
>  	struct swap_info_struct *si,
>  	unsigned long offset)

What I already knew was: there are two locks.  We use one sometimes and
the other at other times.

What I don't know is why there are two locks, and the heuristics why we
choose between them.  This comment doesn't help explain the things I
don't know.
