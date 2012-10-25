Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CDEB76B005D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 22:57:12 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so891238pad.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 19:57:12 -0700 (PDT)
Date: Wed, 24 Oct 2012 19:57:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] mm: compaction: Move migration fail/success stats
 to migrate.c
In-Reply-To: <1350892791-2682-2-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1210241953280.2294@chino.kir.corp.google.com>
References: <1350892791-2682-1-git-send-email-mgorman@suse.de> <1350892791-2682-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, 22 Oct 2012, Mel Gorman wrote:

> The compact_pages_moved and compact_pagemigrate_failed events are
> convenient for determining if compaction is active and to what
> degree migration is succeeding but it's at the wrong level. Other
> users of migration may also want to know if migration is working
> properly and this will be particularly true for any automated
> NUMA migration. This patch moves the counters down to migration
> with the new events called pgmigrate_success and pgmigrate_fail.
> The compact_blocks_moved counter is removed because while it was
> useful for debugging initially, it's worthless now as no meaningful
> conclusions can be drawn from its value.
> 

Agreed, "compact_blocks_moved" should have been named 
"compact_blocks_scanned" to accurately describe what it was representing.

> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
