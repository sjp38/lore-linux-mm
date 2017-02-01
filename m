Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF826B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 01:12:53 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so549499775pfb.6
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 22:12:53 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id y19si13481299pgj.37.2017.01.31.22.12.51
        for <linux-mm@kvack.org>;
        Tue, 31 Jan 2017 22:12:52 -0800 (PST)
Date: Wed, 1 Feb 2017 15:12:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170201061248.GA9690@bbox>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
In-Reply-To: <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 31, 2017 at 02:32:08PM +0530, Vinayak Menon wrote:
> During global reclaim, the nr_reclaimed passed to vmpressure
> includes the pages reclaimed from slab. But the corresponding
> scanned slab pages is not passed. This can cause total reclaimed
> pages to be greater than scanned, causing an unsigned underflow
> in vmpressure resulting in a critical event being sent to root
> cgroup. So do not consider reclaimed slab pages for vmpressure
> calculation. The reclaimed pages from slab can be excluded because
> the freeing of a page by slab shrinking depends on each slab's
> object population, making the cost model (i.e. scan:free) different
> from that of LRU. Also, not every shrinker accounts the pages it
> reclaims. This is a regression introduced by commit 6b4f7799c6a5
> ("mm: vmscan: invoke slab shrinkers from shrink_zone()").
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
