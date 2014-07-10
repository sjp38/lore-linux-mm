Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 638FD6B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:14:23 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so8937870wes.32
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:14:22 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id z20si12395452wij.18.2014.07.10.05.14.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:14:22 -0700 (PDT)
Date: Thu, 10 Jul 2014 08:14:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] mm: page_alloc: Abort fair zone allocation policy
 when remotes nodes are encountered
Message-ID: <20140710121419.GM29639@cmpxchg.org>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404893588-21371-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Wed, Jul 09, 2014 at 09:13:07AM +0100, Mel Gorman wrote:
> The purpose of numa_zonelist_order=zone is to preserve lower zones
> for use with 32-bit devices. If locality is preferred then the
> numa_zonelist_order=node policy should be used. Unfortunately, the fair
> zone allocation policy overrides this by skipping zones on remote nodes
> until the lower one is found. While this makes sense from a page aging
> and performance perspective, it breaks the expected zonelist policy. This
> patch restores the expected behaviour for zone-list ordering.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

32-bit NUMA? :-) Anyway, this change also cuts down the fair pass
overhead on bigger NUMA machines, so I'm all for it.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
