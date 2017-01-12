Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66DE76B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:49:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c206so4040628wme.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:49:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j189si1919509wmd.1.2017.01.12.05.49.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 05:49:44 -0800 (PST)
Date: Thu, 12 Jan 2017 13:49:42 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] lib/show_mem.c: teach show_mem to work with the
 given nodemask
Message-ID: <20170112134942.46d6adcjshfeyj4r@suse.de>
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-5-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170112131659.23058-5-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

On Thu, Jan 12, 2017 at 02:16:59PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> show_mem() allows to filter out node specific data which is irrelevant
> to the allocation request via SHOW_MEM_FILTER_NODES. The filtering
> is done in skip_free_areas_node which skips all nodes which are not
> in the mems_allowed of the current process. This works most of the
> time as expected because the nodemask shouldn't be outside of the
> allocating task but there are some exceptions. E.g. memory hotplug might
> want to request allocations from outside of the allowed nodes (see
> new_node_page).
> 
> Get rid of this hardcoded behavior and push the allocation mask down the
> show_mem path and use it instead of cpuset_current_mems_allowed. NULL
> nodemask is interpreted as cpuset_current_mems_allowed.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Fairly marginal but

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
