Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D80C1440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 09:08:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 62so9130156wmw.13
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 06:08:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k65si2326081wme.110.2017.07.14.06.08.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 06:08:45 -0700 (PDT)
Date: Fri, 14 Jul 2017 15:08:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
Message-ID: <20170714130841.GR2618@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-2-mhocko@kernel.org>
 <20170714093650.l67vbem2g4typkta@suse.de>
 <20170714104756.GD2618@dhcp22.suse.cz>
 <20170714111633.gk5rpu2d5ghkbrrd@suse.de>
 <20170714113840.GI2618@dhcp22.suse.cz>
 <20170714125616.clbp4ezgtoon6cmk@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714125616.clbp4ezgtoon6cmk@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri 14-07-17 13:56:16, Mel Gorman wrote:
> Also strongly suggest you continue using proc_dostring because it
> catches all the corner-cases that can occur.

proc_dostring would need a data in sysctl table and I found that more
confusing than having a simplistic read/write. I can do that if you
insist though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
