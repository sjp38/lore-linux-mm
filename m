Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7806A6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:39:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k184so49889754wme.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:39:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xu5si84859889wjb.254.2017.01.05.02.39.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:39:37 -0800 (PST)
Date: Thu, 5 Jan 2017 11:39:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/7 v2] vm, vmscan: enahance vmscan tracepoints
Message-ID: <20170105103933.GJ21618@dhcp22.suse.cz>
References: <20170104101942.4860-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104101942.4860-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Andrew,
it seems that all the patches have been acked. One of the patches has
been refreshed and send as a reply-to original one. One script in the
Documentation directory needs to be updated but I guess this is low
priority.

Should I resubmit what I have with or you are going to pick it up from
here?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
