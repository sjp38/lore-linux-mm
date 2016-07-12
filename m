Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48F556B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 14:18:49 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so16869570lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:18:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s130si2001703wmf.18.2016.07.12.11.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 11:18:48 -0700 (PDT)
Date: Tue, 12 Jul 2016 14:18:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 29/34] mm, page_alloc: remove fair zone allocation policy
Message-ID: <20160712181843.GE7821@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-30-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-30-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:35:05AM +0100, Mel Gorman wrote:
> The fair zone allocation policy interleaves allocation requests between
> zones to avoid an age inversion problem whereby new pages are reclaimed to
> balance a zone.  Reclaim is now node-based so this should no longer be an
> issue and the fair zone allocation policy is not free.  This patch removes
> it.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

It's indeed no longer needed with a single set of LRUs on each NUMA
node. I'm glad this wart is finally going. Thanks Mel.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
