Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16B736B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:19:07 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x204-v6so22604368qka.6
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:19:07 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id q3-v6si1480576qtc.166.2018.07.13.13.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 13:19:06 -0700 (PDT)
Date: Fri, 13 Jul 2018 13:18:58 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH 6/6] swap, put_swap_page: Share more between huge/normal
 code path
Message-ID: <20180713201858.zj43xzsnxqk3ozks@ca-dmjordan1.us.oracle.com>
References: <20180712233636.20629-1-ying.huang@intel.com>
 <20180712233636.20629-7-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712233636.20629-7-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, Jul 13, 2018 at 07:36:36AM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> In this patch, locking related code is shared between huge/normal code
> path in put_swap_page() to reduce code duplication.  And `free_entries
> == 0` case is merged into more general `free_entries !=
> SWAPFILE_CLUSTER` case, because the new locking method makes it easy.

Might be a bit easier to think about the two changes if they were split up.

Agree with Dave's comment from patch 1, but otherwise the series looks ok to
me.  I like the nr_swap_entries macro, that's clever.
