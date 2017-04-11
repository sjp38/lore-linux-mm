Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 843826B03AA
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:15:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id m26so508282wrm.5
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 11:15:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 39si6505237wry.53.2017.04.11.11.15.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 11:15:25 -0700 (PDT)
Date: Tue, 11 Apr 2017 20:15:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170411181519.GC21171@dhcp22.suse.cz>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi,
I didn't get to read though patches yet but the cover letter didn't
really help me to understand the basic concepts to have a good starting
point before diving into implementation details. It contains a lot of
history remarks which is not bad but IMHO too excessive here. I would
appreciate the following information (some of that is already provided
in the cover but could benefit from some rewording/text reorganization).

- what is ZONE_CMA and how it is configured (from admin POV)
- how does ZONE_CMA compare to other zones
- who is allowed to allocate from this zone and what are the
  guarantees/requirements for successful allocation
- how does the zone compare to a preallocate allocation pool
- how is ZONE_CMA balanced/reclaimed due to internal memory pressure
  (from CMA users)
- is this zone reclaimable for the global memory reclaim
- why this was/is controversial
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
