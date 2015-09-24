Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAB982F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 16:01:34 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so265204280wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:01:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s16si718718wiv.39.2015.09.24.13.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 13:01:33 -0700 (PDT)
Date: Thu, 24 Sep 2015 16:01:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/10] mm, page_alloc: Remove unnecessary parameter from
 zone_watermark_ok_safe
Message-ID: <20150924200123.GE3009@cmpxchg.org>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442832762-7247-2-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 21, 2015 at 11:52:33AM +0100, Mel Gorman wrote:
> No user of zone_watermark_ok_safe() specifies alloc_flags. This patch
> removes the unnecessary parameter.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Christoph Lameter <cl@linux.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
