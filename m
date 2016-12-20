Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EACE76B02F1
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 07:31:24 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so24742621wma.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 04:31:24 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id km9si22453156wjb.282.2016.12.20.04.31.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Dec 2016 04:31:23 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id B85A099205
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 12:31:22 +0000 (UTC)
Date: Tue, 20 Dec 2016 12:31:22 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
Message-ID: <20161220123121.e4wgkxm2txdoxogo@techsingularity.net>
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1481522347-20393-2-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>

On Mon, Dec 12, 2016 at 01:59:07PM +0800, Jia He wrote:
> In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
> zone_statistics"), it reconstructed codes to reduce the branch miss rate.
> Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
>  z->node would not be equal to preferred_zone->node. That seems to be
> incorrect.
> 
> Fixes: commit b9f00e147f27 ("mm, page_alloc: reduce branches in
> zone_statistics")
> 
> Signed-off-by: Jia He <hejianet@gmail.com>

This is slightly curious. It appear it would only occur if a process was
running on a node that was outside the memory policy. Can you confirm
that is the case?

If so, your patch is a a semantic curiousity because it's actually
impossible for a NUMA allocation to be local and the definition of "HIT"
is fuzzy enough to be useless.

I won't object to the patch but it makes me trust "hit" even less than I
already do for any analysis.

Note that after this mail that I'll be unavailable by mail until early
new years.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
