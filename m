Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C52326B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 11:26:19 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c206so21568566wme.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:26:19 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 82si1306734wmo.19.2017.01.14.08.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 08:26:18 -0800 (PST)
Date: Sat, 14 Jan 2017 11:26:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] mm, page_alloc: do not report all nodes in show_mem
Message-ID: <20170114162613.GE26139@cmpxchg.org>
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112131659.23058-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
