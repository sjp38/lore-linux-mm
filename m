Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D1BEA82F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 16:06:35 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so265379375wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:06:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bz18si704060wib.94.2015.09.24.13.06.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 13:06:34 -0700 (PDT)
Date: Thu, 24 Sep 2015 16:06:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
Message-ID: <20150924200627.GG3009@cmpxchg.org>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442832762-7247-4-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 21, 2015 at 11:52:35AM +0100, Mel Gorman wrote:
> There is a seqcounter that protects against spurious allocation failures
> when a task is changing the allowed nodes in a cpuset. There is no need
> to check the seqcounter until a cpuset exists.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
