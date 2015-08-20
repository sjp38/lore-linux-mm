Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4056B0255
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 09:45:30 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so146087664wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 06:45:29 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id cn6si12736215wib.103.2015.08.20.06.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 06:45:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id C70B7C8022
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 13:45:27 +0000 (UTC)
Date: Thu, 20 Aug 2015 14:45:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary recalculations
 for dirty zone balancing
Message-ID: <20150820134526.GD12432@techsingularity.net>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-4-git-send-email-mgorman@techsingularity.net>
 <20150820124526.GE20110@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150820124526.GE20110@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 20, 2015 at 02:45:27PM +0200, Michal Hocko wrote:
> On Wed 12-08-15 11:45:28, Mel Gorman wrote:
> > File-backed pages that will be immediately are balanced between zones but
> 					    ^written to...
> 
> > it's unnecessarily expensive.
> 
> to do WHAT? I guess you meant checking gfp_mask resp. alloc_mask? I
> doubt it would make a noticeable difference as this is a slow path
> already but I agree it doesn't make sense to check it again.
> 

File-backed pages that will be immediately written are balanced between
zones.  This heuristic tries to avoid having a single zone filled with
recently dirtied pages but the checks are unnecessarily expensive. Move
consider_zone_balanced into the alloc_context instead of checking bitmaps
multiple times. The patch also gives the parameter a more meaningful name.

?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
