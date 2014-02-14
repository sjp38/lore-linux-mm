Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1396B0038
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 06:04:50 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id hi5so336245wib.15
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 03:04:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si3417303wjs.109.2014.02.14.03.04.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 03:04:49 -0800 (PST)
Date: Fri, 14 Feb 2014 11:04:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V2 2/2] mm/vmscan: not check compaction_ready on promoted
 zones
Message-ID: <20140214110446.GB6732@suse.de>
References: <000201cf2950$07a17ce0$16e476a0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <000201cf2950$07a17ce0$16e476a0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, riel@redhat.com, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On Fri, Feb 14, 2014 at 02:42:34PM +0800, Weijie Yang wrote:
> We abort direct reclaim if find the zone is ready for compaction.
> Sometimes the zone is just a promoted highmem zone to force scan
> pinning highmem, which is not the intended zone the caller want to
> alloc page from. In this situation, setting aborted_reclaim to
> indicate the caller turn back to retry allocation is waste of time
> and could cause a loop in __alloc_pages_slowpath().
> 
> This patch do not check compaction_ready() on promoted zones to avoid
> the above situation, only set aborted_reclaim if the caller intended
> zone is ready to compaction.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
