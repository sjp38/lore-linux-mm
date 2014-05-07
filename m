Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id F096B6B0039
	for <linux-mm@kvack.org>; Wed,  7 May 2014 16:56:30 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j5so1614076qaq.29
        for <linux-mm@kvack.org>; Wed, 07 May 2014 13:56:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v6si7395840qas.91.2014.05.07.13.56.29
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 13:56:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch v3 3/6] mm, compaction: add per-zone migration pfn cache for async compaction
Date: Wed,  7 May 2014 16:56:21 -0400
Message-Id: <536a9dfd.0683e00a.573f.ffff8060SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <alpine.DEB.2.02.1405061921220.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061921220.18635@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 06, 2014 at 07:22:45PM -0700, David Rientjes wrote:
> Each zone has a cached migration scanner pfn for memory compaction so that 
> subsequent calls to memory compaction can start where the previous call left 
> off.
> 
> Currently, the compaction migration scanner only updates the per-zone cached pfn 
> when pageblocks were not skipped for async compaction.  This creates a 
> dependency on calling sync compaction to avoid having subsequent calls to async 
> compaction from scanning an enormous amount of non-MOVABLE pageblocks each time 
> it is called.  On large machines, this could be potentially very expensive.
> 
> This patch adds a per-zone cached migration scanner pfn only for async 
> compaction.  It is updated everytime a pageblock has been scanned in its 
> entirety and when no pages from it were successfully isolated.  The cached 
> migration scanner pfn for sync compaction is updated only when called for sync 
> compaction.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v3: do not update pageblock skip metadata when skipped due to async per
>      Vlastimil.

Looks good to me.
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
