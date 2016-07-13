Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9086B025E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:48:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so30414313wmr.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:48:16 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id z137si11237216wmd.51.2016.07.13.01.48.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 01:48:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id A557498D7B
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:48:14 +0000 (UTC)
Date: Wed, 13 Jul 2016 09:48:13 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 13/34] mm, vmscan: make shrink_node decisions more
 node-centric
Message-ID: <20160713084813.GH9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-14-git-send-email-mgorman@techsingularity.net>
 <20160712143234.GG5881@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160712143234.GG5881@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 10:32:34AM -0400, Johannes Weiner wrote:
> On Fri, Jul 08, 2016 at 10:34:49AM +0100, Mel Gorman wrote:
> > Earlier patches focused on having direct reclaim and kswapd use data that
> > is node-centric for reclaiming but shrink_node() itself still uses too
> > much zone information.  This patch removes unnecessary zone-based
> > information with the most important decision being whether to continue
> > reclaim or not.  Some memcg APIs are adjusted as a result even though
> > memcg itself still uses some zone information.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Second half of the memcg conversion is in the next patch. Ok.

Yeah. I know it bumps the patch count but the combined patch is a headache
to read.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
