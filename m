Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A98506B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 11:42:08 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so43341693lbb.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:42:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o10si44932268wjs.136.2016.06.22.08.42.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 08:42:07 -0700 (PDT)
Subject: Re: [PATCH 12/27] mm, vmscan: Make shrink_node decisions more
 node-centric
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-13-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5c367d62-807d-77e8-6206-58fc207ecb0d@suse.cz>
Date: Wed, 22 Jun 2016 17:42:06 +0200
MIME-Version: 1.0
In-Reply-To: <1466518566-30034-13-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/21/2016 04:15 PM, Mel Gorman wrote:
> Earlier patches focused on having direct reclaim and kswapd use data that
> is node-centric for reclaiming but shrink_node() itself still uses too much
> zone information. This patch removes unnecessary zone-based information
> with the most important decision being whether to continue reclaim or
> not. Some memcg APIs are adjusted as a result even though memcg itself
> still uses some zone information.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
