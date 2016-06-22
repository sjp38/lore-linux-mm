Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CAA0B6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:51:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a4so35917909lfa.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:51:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa10si7075753wjd.236.2016.06.22.05.50.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 05:50:59 -0700 (PDT)
Subject: Re: [PATCH 03/27] mm, vmscan: Move LRU lists to node
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-4-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9c85cef1-32cc-5b99-0b95-8c8f0b14fd65@suse.cz>
Date: Wed, 22 Jun 2016 14:50:57 +0200
MIME-Version: 1.0
In-Reply-To: <1466518566-30034-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/21/2016 04:15 PM, Mel Gorman wrote:
> This moves the LRU lists from the zone to the node and related data
> such as counters, tracing, congestion tracking and writeback tracking.
> Unfortunately, due to reclaim and compaction retry logic, it is necessary
> to account for the number of LRU pages on both zone and node logic. Most
> reclaim logic is based on the node counters but the retry logic uses
> the zone counters which do not distinguish inactive and inactive sizes.
> It would be possible to leave the LRU counters on a per-zone basis but
> it's a heavier calculation across multiple cache lines that is much
> more frequent than the retry checks.
>
> Other than the LRU counters, this is mostly a mechanical patch but note
> that it introduces a number of anomalies. For example, the scans are
> per-zone but using per-node counters. We also mark a node as congested
> when a zone is congested. This causes weird problems that are fixed later
> but is easier to review.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
