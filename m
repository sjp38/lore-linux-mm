Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 672E46B02E1
	for <linux-mm@kvack.org>; Fri, 12 May 2017 12:48:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b86so13067996wmi.6
        for <linux-mm@kvack.org>; Fri, 12 May 2017 09:48:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j6si3394373edh.331.2017.05.12.09.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 09:48:42 -0700 (PDT)
Date: Fri, 12 May 2017 12:48:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: swap: move anonymous THP split logic to vmscan
Message-ID: <20170512164836.GC22367@cmpxchg.org>
References: <87h90sb4jq.fsf@yhuang-dev.intel.com>
 <1494555684-11982-1-git-send-email-minchan@kernel.org>
 <1494555684-11982-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494555684-11982-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 12, 2017 at 11:21:24AM +0900, Minchan Kim wrote:
> The add_to_swap aims to allocate swap_space(ie, swap slot and
> swapcache) so if it fails due to lack of space in case of THP
> or something(hdd swap but tries THP swapout) *caller* rather
> than add_to_swap itself should split the THP page and retry it
> with base page which is more natural.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
