Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B237440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:39:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i185so8382165wmi.7
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:39:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24si5079734wra.224.2017.07.14.02.39.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 02:39:44 -0700 (PDT)
Date: Fri, 14 Jul 2017 10:39:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/9] mm, page_alloc: remove boot pageset initialization
 from memory hotplug
Message-ID: <20170714093942.jzxq4jruixoj22x2@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170714080006.7250-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Jul 14, 2017 at 09:59:59AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> boot_pageset is a boot time hack which gets superseded by normal
> pagesets later in the boot process. It makes zero sense to reinitialize
> it again and again during memory hotplug.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

You could also go slightly further and remove the batch parameter to
setupo_pageset because it's always 0. Otherwise

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
