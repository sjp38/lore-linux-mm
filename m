Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B16F6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:47:22 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r144so4037213wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:47:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo9si7465635wjb.202.2017.01.12.05.47.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 05:47:21 -0800 (PST)
Date: Thu, 12 Jan 2017 13:47:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/4] mm, page_alloc: do not report all nodes in show_mem
Message-ID: <20170112134718.jginjco4qsz5lboh@suse.de>
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170112131659.23058-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

On Thu, Jan 12, 2017 at 02:16:56PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 599d0c954f91 ("mm, vmscan: move LRU lists to node") has added per numa
> node statistics to show_mem but it forgot to add skip_free_areas_node
> to fileter out nodes which are outside of the allocating task numa
> policy. Add this check to not pollute the output with the pointless
> information.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
