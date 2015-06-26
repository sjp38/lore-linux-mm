Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 16AEE6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 07:04:30 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so42225179wiw.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 04:04:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si2296806wiy.3.2015.06.26.04.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 04:04:28 -0700 (PDT)
Date: Fri, 26 Jun 2015 12:04:24 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: fix set pageblock migratetype when boot
Message-ID: <20150626110424.GI26927@suse.de>
References: <558D24C1.5020901@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <558D24C1.5020901@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, David Rientjes <rientjes@google.com>, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 26, 2015 at 06:09:05PM +0800, Xishi Qiu wrote:
> memmap_init_zone()
> 	...
> 	if ((z->zone_start_pfn <= pfn)
> 	    && (pfn < zone_end_pfn(z))
> 	    && !(pfn & (pageblock_nr_pages - 1)))
> 		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> 	...
> 
> If the pfn does not align to pageblock, it will not init the migratetype.

What important impact does that have? It should leave a partial pageblock
as MIGRATE_UNMOVABLE which is fine by me.

> So call it for every page, it will takes more time, but it doesn't matter, 
> this function will be called only in boot or hotadd memory.
> 

It's a lot of additional overhead to add to memory initialisation. It
would need to be for an excellent reason with no alternative solution.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
