Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1667F6B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 22:10:33 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id o4L2AUlO021061
	for <linux-mm@kvack.org>; Thu, 20 May 2010 19:10:30 -0700
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by hpaq11.eem.corp.google.com with ESMTP id o4L2ASf5024580
	for <linux-mm@kvack.org>; Thu, 20 May 2010 19:10:29 -0700
Received: by pvf33 with SMTP id 33so247803pvf.26
        for <linux-mm@kvack.org>; Thu, 20 May 2010 19:10:28 -0700 (PDT)
Date: Thu, 20 May 2010 19:10:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at
 first
In-Reply-To: <20100521103935.1E56.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.1005201859260.23122@tigran.mtv.corp.google.com>
References: <20100519174327.9591.A69D9226@jp.fujitsu.com> <alpine.DEB.1.00.1005201822120.19421@tigran.mtv.corp.google.com> <20100521103935.1E56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010, KOSAKI Motohiro wrote:
> 
> > Acked-by: Hugh Dickins <hughd@google.com>
> > 
> > Thanks - though I don't quite agree with your description: I can't
> > see why the lru_cache_add_active_anon() was ever justified - that
> > "active" came in along with the separate anon and file LRU lists.
> 
> If you have any worry, can you please share it? I'll test such workload
> and fix the issue if necessary. You are expert than me in this area.

?? I've acked the patch: my worry is only with the detail of your
comments on the history - in my view it was always wrong to put on
the active LRU there, and I'm glad that you have now fixed it.

If you really want to test some workload on 2.6.28 to see if it too
works better with your fix, I won't stop you - but I'd much prefer
you to be applying your mind to 2.6.35 and 2.6.36!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
