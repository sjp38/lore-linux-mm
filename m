Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCA216B027A
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:57:10 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so7933736wmv.5
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:57:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y62si3649963wrc.154.2017.01.19.00.57.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 00:57:09 -0800 (PST)
Date: Thu, 19 Jan 2017 09:57:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, page_alloc: warn_alloc nodemask is NULL when
 cpusets are disabled
Message-ID: <20170119085706.GH30786@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com>
 <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 19-01-17 08:29:45, Vlastimil Babka wrote:
> On 01/18/2017 10:51 PM, David Rientjes wrote:
> > The patch "mm, page_alloc: warn_alloc print nodemask" implicitly sets the 
> > allocation nodemask to cpuset_current_mems_allowed when there is no 
> > effective mempolicy.  cpuset_current_mems_allowed is only effective when 
> > cpusets are enabled, which is also printed by warn_alloc(), so setting 
> > the nodemask to cpuset_current_mems_allowed is redundant and prevents 
> > debugging issues where ac->nodemask is not set properly in the page 
> > allocator.
> > 
> > This provides better debugging output since 
> > cpuset_print_current_mems_allowed() is already provided.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Yes, with my current cpuset vs mempolicy debugging experience, this is
> more useful (except how both nodemask and mems_allowed can change under
> us, so what we print here is not necessarily the same that what
> get_page_from_freelist() has seen, but that's another thing...).
> 
> But I would suggest you change the oom killer's dump_header() the same
> way than warn_alloc().

Yes please

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
