Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 809E56B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 10:25:32 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so37763413wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 07:25:32 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id er10si12945524wib.87.2015.08.20.07.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 07:25:31 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so37762846wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 07:25:30 -0700 (PDT)
Date: Thu, 20 Aug 2015 16:25:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary recalculations
 for dirty zone balancing
Message-ID: <20150820142529.GJ20110@dhcp22.suse.cz>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-4-git-send-email-mgorman@techsingularity.net>
 <20150820124526.GE20110@dhcp22.suse.cz>
 <20150820134526.GD12432@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820134526.GD12432@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-08-15 14:45:26, Mel Gorman wrote:
> On Thu, Aug 20, 2015 at 02:45:27PM +0200, Michal Hocko wrote:
> > On Wed 12-08-15 11:45:28, Mel Gorman wrote:
> > > File-backed pages that will be immediately are balanced between zones but
> > 					    ^written to...
> > 
> > > it's unnecessarily expensive.
> > 
> > to do WHAT? I guess you meant checking gfp_mask resp. alloc_mask? I
> > doubt it would make a noticeable difference as this is a slow path
> > already but I agree it doesn't make sense to check it again.
> > 
> 
> File-backed pages that will be immediately written are balanced between
> zones.  This heuristic tries to avoid having a single zone filled with
> recently dirtied pages but the checks are unnecessarily expensive. Move
> consider_zone_balanced into the alloc_context instead of checking bitmaps
> multiple times. The patch also gives the parameter a more meaningful name.

Sounds much better. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
