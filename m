Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B56DE6B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:51:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l184so36357481lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:51:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l184si22288029wmg.12.2016.06.17.01.51.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 01:51:14 -0700 (PDT)
Subject: Re: [PATCH 19/27] mm: Move vmscan writes and file write accounting to
 the node
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-20-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9bafe5ce-9cee-4c83-28a2-df2fb453af19@suse.cz>
Date: Fri, 17 Jun 2016 10:51:13 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-20-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> As reclaim is now node-based, it follows that page write activity
> due to page reclaim should also be accounted for on the node. For
> consistency, also account page writes and page dirtying on a per-node
> basis.
>
> After this patch, there are a few remaining zone counters that may
> appear strange but are fine. NUMA stats are still per-zone as this is a
> user-space interface that tools consume. NR_MLOCK, NR_SLAB_*, NR_PAGETABLE,
> NR_KERNEL_STACK and NR_BOUNCE are all allocations that potentially pin
> low memory and cannot trivially be reclaimed on demand. This information
> is still useful for debugging a page allocation failure warning.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
