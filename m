Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id A60566B00CF
	for <linux-mm@kvack.org>; Thu,  8 May 2014 04:51:57 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so1434254eek.41
        for <linux-mm@kvack.org>; Thu, 08 May 2014 01:51:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si1026568eef.172.2014.05.08.01.51.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 01:51:56 -0700 (PDT)
Date: Thu, 8 May 2014 09:51:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list
 placement of CMA and RESERVE pages
Message-ID: <20140508085148.GK23991@suse.de>
References: <533D8015.1000106@suse.cz>
 <1396539618-31362-1-git-send-email-vbabka@suse.cz>
 <1396539618-31362-2-git-send-email-vbabka@suse.cz>
 <53616F39.2070001@oracle.com>
 <53638ADA.5040200@suse.cz>
 <5367A1E5.2020903@oracle.com>
 <5367B356.1030403@suse.cz>
 <20140507013333.GB26212@bbox>
 <536A4A3B.1090403@suse.cz>
 <20140508055421.GC9161@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140508055421.GC9161@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong-Taek Lee <ytk.lee@samsung.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On Thu, May 08, 2014 at 02:54:21PM +0900, Joonsoo Kim wrote:
> > >> Furthermore, I think there's a problem that
> > >> setup_zone_migrate_reserve() operates on pageblocks, but as MAX_ODER
> > >> is higher than pageblock_order, RESERVE pages might be merged with
> > >> buddies of different migratetype and end up on their free_list. That
> > >> seems to me like a flaw in the design of reserves, but perhaps
> > >> others won't think it's serious enough to fix?
> 
> I wanna know who want MIGRATE_RESERVE. On my previous testing, one
> pageblock for MIGRATE_RESERVE is merged with buddies of different
> migratetype during boot-up and never come back again. But my system works
> well. :)
> 

It's important for short-lived high-order atomic allocations.
MIGRATE_RESERVE preserves a property of the buddy allocator prior to the
merging of fragmentation avoidance. Most users will not notice as not
many drivers depend on these allocations working. If they are getting
destroyed at boot-up, it's a bug.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
