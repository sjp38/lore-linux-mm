Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65F136B0069
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:48:02 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id p192so4041298wme.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:48:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j136si1893466wmf.102.2017.01.12.05.48.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 05:48:01 -0800 (PST)
Date: Thu, 12 Jan 2017 13:47:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm, page_alloc: warn_alloc print nodemask
Message-ID: <20170112134758.zmryorv6o5i7i5fx@suse.de>
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170112131659.23058-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

On Thu, Jan 12, 2017 at 02:16:57PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> warn_alloc is currently used for to report an allocation failure or an
> allocation stall. We print some details of the allocation request like
> the gfp mask and the request order. We do not print the allocation
> nodemask which is important when debugging the reason for the allocation
> failure as well. We alreaddy print the nodemask in the OOM report.
> 
> Add nodemask to warn_alloc and print it in warn_alloc as well.
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
