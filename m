Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D2FDA280319
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 09:12:58 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so81979791wgx.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:12:58 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id et10si400732wib.62.2015.07.17.06.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 06:12:57 -0700 (PDT)
Date: Fri, 17 Jul 2015 15:12:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/3] mm, meminit: replace rwsem with completion
Message-ID: <20150717131252.GL19282@twins.programming.kicks-ass.net>
References: <1437135724-20110-1-git-send-email-mgorman@suse.de>
 <1437135724-20110-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437135724-20110-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nicolai Stange <nicstange@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 17, 2015 at 01:22:02PM +0100, Mel Gorman wrote:
> From: Nicolai Stange <nicstange@gmail.com>
> 
> Commit 0e1cc95b4cc7 ("mm: meminit: finish initialisation of struct pages
> before basic setup") introduced a rwsem to signal completion of the
> initialization workers.
> 
> Lockdep complains about possible recursive locking:
>   =============================================
>   [ INFO: possible recursive locking detected ]
>   4.1.0-12802-g1dc51b8 #3 Not tainted
>   ---------------------------------------------
>   swapper/0/1 is trying to acquire lock:
>   (pgdat_init_rwsem){++++.+},
>     at: [<ffffffff8424c7fb>] page_alloc_init_late+0xc7/0xe6
> 
>   but task is already holding lock:
>   (pgdat_init_rwsem){++++.+},
>     at: [<ffffffff8424c772>] page_alloc_init_late+0x3e/0xe6
> 
> Replace the rwsem by a completion together with an atomic
> "outstanding work counter".
> 
> [peterz@infradead.org: Barrier removal on the grounds of being pointless]
> [mgorman@suse.de: Applied review feedback]
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
