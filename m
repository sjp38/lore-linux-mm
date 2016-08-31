Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DBE16B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:46:58 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so35775978lfw.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 05:46:58 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id b190si23566222wmf.127.2016.08.31.05.46.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 05:46:56 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id E841398981
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 12:46:55 +0000 (UTC)
Date: Wed, 31 Aug 2016 13:46:54 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 07/34] mm, vmscan: make kswapd reclaim in terms of nodes
Message-ID: <20160831124654.GZ8119@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-8-git-send-email-mgorman@techsingularity.net>
 <20160829093844.GA2592@linux.vnet.ibm.com>
 <20160830120728.GV8119@techsingularity.net>
 <20160830142508.GA10514@linux.vnet.ibm.com>
 <20160830150051.GW8119@techsingularity.net>
 <20160831060959.GA6787@linux.vnet.ibm.com>
 <20160831084942.GX8119@techsingularity.net>
 <20160831110932.GB21661@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160831110932.GB21661@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>

On Wed, Aug 31, 2016 at 01:09:33PM +0200, Michal Hocko wrote:
> > We cannot just convert populated_zone() as many existing users really
> > need to check for present_pages. This patch introduces a managed_zone()
> > helper and uses it in the few cases where it is critical that the check
> > is made for managed pages -- zonelist constuction and page reclaim.
> 
> OK, the patch makes sense to me. I am not happy about two very similar
> functions, to be honest though. managed vs. present checks will be quite
> subtle and it is not entirely clear when to use which one.

In the vast majority of cases, the distinction is irrelevant. The patch
only updates the places where it really matters to minimise any
confusion.

> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

> /*
>  * Returns true if a zone has pages managed by the buddy allocator.
>  * All the reclaim decisions have to use this function rather than
>  * populated_zone(). If the whole zone is reserved then we can easily
>  * end up with populated_zone() && !managed_zone().
>  */
> 
> What do you think?
> 

This makes a lot of sense. I've updated the patch and will await a test
from Srikar before reposting.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
