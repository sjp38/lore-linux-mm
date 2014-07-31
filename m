Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 94F896B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:07:41 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so2924919wev.13
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:07:39 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id gt8si12746919wib.65.2014.07.31.08.07.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 08:07:10 -0700 (PDT)
Date: Thu, 31 Jul 2014 11:06:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg, vmscan: Fix forced scan of anonymous pages
Message-ID: <20140731150653.GA9952@cmpxchg.org>
References: <1406807385-5168-1-git-send-email-jmarchan@redhat.com>
 <1406807385-5168-3-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406807385-5168-3-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>

On Thu, Jul 31, 2014 at 01:49:45PM +0200, Jerome Marchand wrote:
> When memory cgoups are enabled, the code that decides to force to scan
> anonymous pages in get_scan_count() compares global values (free,
> high_watermark) to a value that is restricted to a memory cgroup
> (file). It make the code over-eager to force anon scan.
> 
> For instance, it will force anon scan when scanning a memcg that is
> mainly populated by anonymous page, even when there is plenty of file
> pages to get rid of in others memcgs, even when swappiness == 0. It
> breaks user's expectation about swappiness and hurts performance. 
> 
> This patch make sure that forced anon scan only happens when there not
> enough file pages for the all zone, not just in one random memcg.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
