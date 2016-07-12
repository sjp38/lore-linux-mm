Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 101E56B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 13:18:57 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so16120113lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:18:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v132si725954wmd.83.2016.07.12.10.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 10:18:56 -0700 (PDT)
Date: Tue, 12 Jul 2016 13:18:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 21/34] mm, vmscan: only wakeup kswapd once per node for
 the requested classzone
Message-ID: <20160712171845.GA7307@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-22-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-22-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:57AM +0100, Mel Gorman wrote:
> kswapd is woken when zones are below the low watermark but the wakeup
> decision is not taking the classzone into account.  Now that reclaim is
> node-based, it is only required to wake kswapd once per node and only if
> all zones are unbalanced for the requested classzone.
> 
> Note that one node might be checked multiple times if the zonelist is
> ordered by node because there is no cheap way of tracking what nodes have
> already been visited.  For zone-ordering, each node should be checked only
> once.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
