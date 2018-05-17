Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7E066B04E7
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:21:14 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u20-v6so3088456wru.14
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:21:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2-v6si5180482edd.8.2018.05.17.06.21.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 May 2018 06:21:13 -0700 (PDT)
Date: Thu, 17 May 2018 15:21:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180517132109.GU12670@dhcp22.suse.cz>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ville Syrjala <ville.syrjala@linux.intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> From: Ville Syrjala <ville.syrjala@linux.intel.com>
> 
> This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> 
> Make x86 with HIGHMEM=y and CMA=y boot again.

Is there any bug report with some more details? It is much more
preferable to fix the issue rather than to revert the whole thing
right away.
-- 
Michal Hocko
SUSE Labs
