Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA876B0254
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:42:04 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so213747571wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:42:04 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m74si41237714wmc.49.2016.02.23.10.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:42:03 -0800 (PST)
Date: Tue, 23 Feb 2016 10:42:00 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/27] mm, vmscan: Move LRU lists to node
Message-ID: <20160223184200.GE13816@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-6-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-6-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:28PM +0000, Mel Gorman wrote:
> This moves the LRU lists from the zone to the node and all related data
> such as counters, tracing, congestion tracking and writeback tracking.
> This is mostly a mechanical patch but note that it introduces a number
> of anomalies. For example, the scans are per-zone but using per-node
> counters. We also mark a node as congested when a zone is congested. This
> causes weird problems that are fixed later but is easier to review.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Same rules apply as in the previous patch. Looks good, FWIW.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
