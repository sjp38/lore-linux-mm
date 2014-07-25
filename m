Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id CA1456B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 11:39:04 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so4404583wgg.19
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:39:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t19si3235111wij.95.2014.07.25.08.39.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 08:39:02 -0700 (PDT)
Date: Fri, 25 Jul 2014 16:38:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, thp: restructure thp avoidance of light synchronous
 migration
Message-ID: <20140725153859.GK10819@suse.de>
References: <alpine.DEB.2.02.1407241540190.22557@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407241540190.22557@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 24, 2014 at 03:41:06PM -0700, David Rientjes wrote:
> __GFP_NO_KSWAPD, once the way to determine if an allocation was for thp or not, 
> has gained more users.  Their use is not necessarily wrong, they are trying to 
> do a memory allocation that can easily fail without disturbing kswapd, so the 
> bit has gained additional usecases.
> 
> This restructures the check to determine whether MIGRATE_SYNC_LIGHT should be 
> used for memory compaction in the page allocator.  Rather than testing solely 
> for __GFP_NO_KSWAPD, test for all bits that must be set for thp allocations.
> 
> This also moves the check to be done only after the page allocator is aborted 
> for deferred or contended memory compaction since setting migration_mode for 
> this case is pointless.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
