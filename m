Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E12476B00C0
	for <linux-mm@kvack.org>; Thu,  8 May 2014 01:16:01 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so2246096pab.0
        for <linux-mm@kvack.org>; Wed, 07 May 2014 22:16:01 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vw5si14898634pab.210.2014.05.07.22.15.59
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 22:16:00 -0700 (PDT)
Date: Thu, 8 May 2014 14:17:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch v3 6/6] mm, compaction: terminate async compaction when
 rescheduling
Message-ID: <20140508051747.GA9161@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 06, 2014 at 07:22:52PM -0700, David Rientjes wrote:
> Async compaction terminates prematurely when need_resched(), see
> compact_checklock_irqsave().  This can never trigger, however, if the 
> cond_resched() in isolate_migratepages_range() always takes care of the 
> scheduling.
> 
> If the cond_resched() actually triggers, then terminate this pageblock scan for 
> async compaction as well.

Hello,

I think that same logic would be helpful to cond_resched() in
isolatate_freepages(). And, isolate_freepages() doesn't have exit logic
when it find zone_lock contention. I think that fixing it is also
helpful.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
