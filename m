Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B3F686B0264
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 13:26:16 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so86290376ith.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 10:26:16 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id z185si14241375itg.13.2016.06.13.10.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 10:26:15 -0700 (PDT)
Date: Mon, 13 Jun 2016 12:26:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 01/27] mm, vmstat: Add infrastructure for per-node
 vmstats
In-Reply-To: <1465495483-11855-2-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1606131208110.25027@east.gentwo.org>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net> <1465495483-11855-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 Jun 2016, Mel Gorman wrote:

> VM statistic counters for reclaim decisions are zone-based. If the kernel
> is to reclaim on a per-node basis then we need to track per-node statistics
> but there is no infrastructure for that. The most notable change is that

There is node_page_state() so the value of any counter per node is already
available. Note that some of the counters (NUMA_xx) for example do not
make much sense as per zone counters and are effectively used as per node
counters.

So the main effect you are looking for is to have the counters stored in
the per node structure as opposed to the per zone struct in order to
avoid the summing? Doing so duplicates a large amount of code it seems.

If you do this then also move over certain counters that have more of a
per node use from per zone to per node. Like the NUMA_xxx counters.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
