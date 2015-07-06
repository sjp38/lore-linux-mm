Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 084A228029D
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 04:21:53 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so133006446wgj.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 01:21:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eo8si29690595wib.7.2015.07.06.01.21.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 01:21:51 -0700 (PDT)
Date: Mon, 6 Jul 2015 09:21:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/page_alloc: deferred meminit: replace rwsem with
 completion
Message-ID: <20150706082143.GG6812@suse.de>
References: <87k2uecf6t.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87k2uecf6t.fsf@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolai Stange <nicstange@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 06, 2015 at 02:17:30AM +0200, Nicolai Stange wrote:
> Commit 0e1cc95b4cc7
>   ("mm: meminit: finish initialisation of struct pages before basic setup")
> introduced a rwsem to signal completion of the initialization workers.
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
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
