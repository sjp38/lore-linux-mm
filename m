Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 200AD6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 13:28:52 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so16263738lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:28:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q6si21880848wmd.22.2016.07.12.10.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 10:28:51 -0700 (PDT)
Date: Tue, 12 Jul 2016 13:28:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 23/34] mm: convert zone_reclaim to node_reclaim
Message-ID: <20160712172846.GC7307@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-24-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-24-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:59AM +0100, Mel Gorman wrote:
> As reclaim is now per-node based, convert zone_reclaim to be node_reclaim.
> It is possible that a node will be reclaimed multiple times if it has
> multiple zones but this is unavoidable without caching all nodes traversed
> so far.  The documentation and interface to userspace is the same from a
> configuration perspective and will will be similar in behaviour unless the
> node-local allocation requests were also limited to lower zones.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
