Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25DDF6B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 12:04:51 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id na2so29385676lbb.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:04:51 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id za4si6138870wjb.174.2016.06.16.09.04.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 09:04:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 94BD9992C0
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 16:04:49 +0000 (UTC)
Date: Thu, 16 Jun 2016 17:04:48 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 16/27] mm: Move page mapped accounting to the node
Message-ID: <20160616160448.GL1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-17-git-send-email-mgorman@techsingularity.net>
 <5c8812fc-f2d3-3008-74ba-9072ae8c7cb3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5c8812fc-f2d3-3008-74ba-9072ae8c7cb3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 16, 2016 at 05:52:59PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> >Reclaim makes decisions based on the number of file pages that are mapped but
> >it's mixing node and zone information. Account NR_FILE_MAPPED pages on the node.
> 
> And NR_ANON_PAGES.
> 

Yes.

> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> I've noticed some new "page_zone(page)->zone_pgdat" instances here.
> 

FWIW, I created a page_pgdat helper and converted all patterns like this
introduced by the series to the helper. There are other potential users
of the helper in the tree that are not touched by the patches but I left
them to preserve history.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
