Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 688846B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 12:30:29 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so36510476wmi.6
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 09:30:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ur3si63081083wjb.33.2016.12.30.09.30.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 09:30:28 -0800 (PST)
Date: Fri, 30 Dec 2016 18:30:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20161230173023.GA4962@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz>
 <20161230160456.GA7267@bbox>
 <20161230163742.GK13301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230163742.GK13301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-12-16 17:37:42, Michal Hocko wrote:
> On Sat 31-12-16 01:04:56, Minchan Kim wrote:
[...]
> > > 	- nr_rotated pages which tells us that we are hitting referenced
> > > 	  pages which are deactivated. If this is a large part of the
> > > 	  reported nr_deactivated pages then the active list is too small
> > 
> > It might be but not exactly. If your goal is to know LRU size, it can be
> > done in get_scan_count. I tend to agree LRU size is helpful for
> > performance analysis because decreased LRU size signals memory shortage
> > then performance drop.
> 
> No, I am not really interested in the exact size but rather to allow to
> find whether we are aging the active list too early...

But thinking about that some more, maybe sticking with the nr_rotated
terminology is rather confusing and displaying the value as nr_referenced
would be more clear.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
