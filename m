Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 299ED6B0389
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:57:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d66so2508008wmi.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 01:57:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j186si2370288wma.13.2017.03.17.01.57.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 01:57:39 -0700 (PDT)
Date: Fri, 17 Mar 2017 09:57:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, vmstat: print non-populated zones in zoneinfo
Message-ID: <20170317085737.GE26298@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com>
 <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
 <20170308144159.GD11034@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308144159.GD11034@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 08-03-17 15:41:59, Michal Hocko wrote:
> On Fri 03-03-17 14:53:07, David Rientjes wrote:
> > Initscripts can use the information (protection levels) from
> > /proc/zoneinfo to configure vm.lowmem_reserve_ratio at boot.
> > 
> > vm.lowmem_reserve_ratio is an array of ratios for each configured zone on
> > the system.  If a zone is not populated on an arch, /proc/zoneinfo
> > suppresses its output.
> > 
> > This results in there not being a 1:1 mapping between the set of zones
> > emitted by /proc/zoneinfo and the zones configured by
> > vm.lowmem_reserve_ratio.
> >
> > This patch shows statistics for non-populated zones in /proc/zoneinfo.
> > The zones exist and hold a spot in the vm.lowmem_reserve_ratio array.
> > Without this patch, it is not possible to determine which index in the
> > array controls which zone if one or more zones on the system are not
> > populated.
> > 
> > Remaining users of walk_zones_in_node() are unchanged.  Files such as
> > /proc/pagetypeinfo require certain zone data to be initialized properly
> > for display, which is not done for unpopulated zones.
> 
> Does it really make sense to print any counters of that zone though?
> Your follow up patch just suggests that we don't want some but what
> about others?
> 
> I can see how skipping empty zones completely can be clumsy but wouldn't
> it be sufficient to just provide
> 
> Node $NUM, zone $NAME
> (unpopulated)
> 
> instead?

ping
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
