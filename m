Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B476F2806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:10:13 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l132so61806736oia.10
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 09:10:13 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e3si10721204plb.171.2017.04.21.09.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 09:10:12 -0700 (PDT)
Message-ID: <1492791012.3209.2.camel@linux.intel.com>
Subject: Re: [PATCH -mm] mm, swap: Fix swap space leak in error path of
 swap_free_entries()
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 21 Apr 2017 09:10:12 -0700
In-Reply-To: <20170421124739.24534-1-ying.huang@intel.com>
References: <20170421124739.24534-1-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

On Fri, 2017-04-21 at 20:47 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> In swapcache_free_entries(), if swap_info_get_cont() return NULL,
> something wrong occurs for the swap entry.A A But we should still
> continue to free the following swap entries in the array instead of
> skip them to avoid swap space leak.A A This is just problem in error
> path, where system may be in an inconsistent state, but it is still
> good to fix it.
> 

Acked-by: Tim Chen <tim.c.chen@linux.intel.com>

> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
