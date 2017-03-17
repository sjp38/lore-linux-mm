Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A25206B0389
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:21:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q126so166653506pga.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:21:14 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id w24si283589pgc.301.2017.03.17.14.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 14:21:13 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id o126so42521914pfb.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:21:13 -0700 (PDT)
Date: Fri, 17 Mar 2017 14:21:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, vmstat: print non-populated zones in zoneinfo
In-Reply-To: <20170317085737.GE26298@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1703171416070.81333@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com> <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com> <alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com> <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
 <20170308144159.GD11034@dhcp22.suse.cz> <20170317085737.GE26298@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Mar 2017, Michal Hocko wrote:

> > Does it really make sense to print any counters of that zone though?
> > Your follow up patch just suggests that we don't want some but what
> > about others?
> > 

Managed and present pages needs to be emitted for userspace parsing of 
memory hotplug, I chose not to suppress the five or six other members 
since the risk of breaking existing parsers far outweighs any savings from 
not emitting these lines.  There is already plenty of opportunities to 
clean /proc/zoneinfo up as described by Andrew that may be possible but 
care needs to taken to ensure we don't break existing readers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
