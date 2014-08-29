Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id D37206B0055
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 04:12:17 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id s7so2155202lbd.21
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 01:12:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6si8639161lar.128.2014.08.29.01.12.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 01:12:15 -0700 (PDT)
Date: Fri, 29 Aug 2014 09:12:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: page_alloc: avoid wakeup kswapd on the unintended
 node
Message-ID: <20140829081211.GF12424@suse.de>
References: <000001cfc357$74db64a0$5e922de0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <000001cfc357$74db64a0$5e922de0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, rientjes@google.com, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Fri, Aug 29, 2014 at 03:03:19PM +0800, Weijie Yang wrote:
> When enter page_alloc slowpath, we wakeup kswapd on every pgdat
> according to the zonelist and high_zoneidx. However, this doesn't
> take nodemask into account, and could prematurely wakeup kswapd on
> some unintended nodes.
> 
> This patch uses for_each_zone_zonelist_nodemask() instead of
> for_each_zone_zonelist() in wake_all_kswapds() to avoid the above situation.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Just out of curiousity, did you measure a problem due to this or is
the patch due to code inspection? It was known that we examined useless
nodes but assumed to not be a problem because the watermark check should
prevent spurious wakeups.  However, we do a cpuset check and this patch
is consistent with that so regardless of why you wrote the patch

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
