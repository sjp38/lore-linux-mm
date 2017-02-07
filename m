Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 119646B025E
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:41:24 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so26417115wjb.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:41:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si5441340wrc.310.2017.02.07.07.41.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 07:41:22 -0800 (PST)
Date: Tue, 7 Feb 2017 16:41:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170207154120.GW5065@dhcp22.suse.cz>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
 <20170207153247.GB31837@WeideMBP.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207153247.GB31837@WeideMBP.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 07-02-17 23:32:47, Wei Yang wrote:
> On Tue, Feb 07, 2017 at 10:45:57AM +0100, Michal Hocko wrote:
[...]
> >Is there any reason why for_each_mem_pfn_range cannot be changed to
> >honor the given start/end pfns instead? I can imagine that a small zone
> >would see a similar pointless iterations...
> >
> 
> Hmm... No special reason, just not thought about this implementation. And
> actually I just do the similar thing as in zone_spanned_pages_in_node(), in
> which also return 0 when there is no overlap.
> 
> BTW, I don't get your point. You wish to put the check in
> for_each_mem_pfn_range() definition?

My point was that you are handling one special case (an empty zone) but
the underlying problem is that __absent_pages_in_range might be wasting
cycles iterating over memblocks that are way outside of the given pfn
range. At least this is my understanding. If you fix that you do not
need the special case, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
