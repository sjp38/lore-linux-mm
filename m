Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 78D7C6B0257
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 15:03:20 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so33981469wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:03:20 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 14si6412824wjx.23.2015.09.25.12.03.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 12:03:19 -0700 (PDT)
Date: Fri, 25 Sep 2015 15:03:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/10] mm, page_alloc: Rename __GFP_WAIT to __GFP_RECLAIM
Message-ID: <20150925190301.GB16359@cmpxchg.org>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 21, 2015 at 11:52:38AM +0100, Mel Gorman wrote:
> __GFP_WAIT was used to signal that the caller was in atomic context and
> could not sleep.  Now it is possible to distinguish between true atomic
> context and callers that are not willing to sleep. The latter should clear
> __GFP_DIRECT_RECLAIM so kswapd will still wake. As clearing __GFP_WAIT
> behaves differently, there is a risk that people will clear the wrong
> flags. This patch renames __GFP_WAIT to __GFP_RECLAIM to clearly indicate
> what it does -- setting it allows all reclaim activity, clearing them
> prevents it.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
