Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C8E9982F69
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 18:25:32 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so52822716pad.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 15:25:32 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id cb8si3847929pad.135.2015.09.30.15.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 15:25:32 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so52227620pab.3
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 15:25:32 -0700 (PDT)
Date: Wed, 30 Sep 2015 15:25:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/10] mm, page_alloc: Rename __GFP_WAIT to
 __GFP_RECLAIM
In-Reply-To: <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1509301525200.23324@chino.kir.corp.google.com>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net> <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 Sep 2015, Mel Gorman wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
