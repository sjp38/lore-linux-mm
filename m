Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9E66B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:34:27 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so319879eaj.29
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 07:34:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si24162692eem.124.2013.12.12.07.34.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 07:34:26 -0800 (PST)
Date: Thu, 12 Dec 2013 15:34:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/4] Configurable fair allocation zone policy
Message-ID: <20131212153422.GJ11295@suse.de>
References: <1386860779-2301-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386860779-2301-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 12, 2013 at 03:06:15PM +0000, Mel Gorman wrote:
> Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
> bug whereby new pages could be reclaimed before old pages because of how
> the page allocator and kswapd interacted on the per-zone LRU lists.
> 
> Unfortunately a side-effect missed during review was that it's now very
> easy to allocate remote memory on NUMA machines. The problem is that
> it is not a simple case of just restoring local allocation policies as
> there are genuine reasons why global page aging may be prefereable. It's
> still a major change to default behaviour so this patch makes the policy
> configurable and sets what I think is a sensible default.
> 
> The patches are on top of some NUMA balancing patches currently in -mm.
> The first patch in the series is a patch posted by Johannes that must be
> taken into account before any of my patches on top. The last patch of the
> series is what alters default behaviour and makes the fair zone allocator
> policy configurable.
> 
> Sniff test results based on following kernels
> 
> vanilla		 3.13-rc3 stock
> instrument-v5r1  NUMA balancing patches just to rule out any conflicts there
> lruslabonly-v1r2 Patch 1 only
> local-v1r2	 Full series
> 

These figures need to be redone. The instrument-v5r1 and later kernels
included a debugging patch that increases migration rates to trigger
another bug. The figures of local-v1r2 relative to instrument-v5r1 are
fine but not relative to 3.13.0-rc3-vanilla

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
