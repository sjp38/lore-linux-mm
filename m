Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA2536B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:55:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so30658924wmr.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:55:19 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id h16si26753434wme.64.2016.07.13.01.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 01:55:18 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id EC7CC1C1FD7
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:55:17 +0100 (IST)
Date: Wed, 13 Jul 2016 09:55:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 18/34] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160713085516.GI9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
 <20160712145801.GJ5881@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160712145801.GJ5881@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 10:58:01AM -0400, Johannes Weiner wrote:
> On Fri, Jul 08, 2016 at 10:34:54AM +0100, Mel Gorman wrote:
> > NR_FILE_PAGES  is the number of        file pages.
> > NR_FILE_MAPPED is the number of mapped file pages.
> > NR_ANON_PAGES  is the number of mapped anon pages.
> > 
> > This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and
> > NR_ANON_PAGES for mapped pages.  This patch renames NR_ANON_PAGES so we
> > have
> > 
> > NR_FILE_PAGES  is the number of        file pages.
> > NR_FILE_MAPPED is the number of mapped file pages.
> > NR_ANON_MAPPED is the number of mapped anon pages.
> 
> That looks wrong to me. The symmetry is between NR_FILE_PAGES and
> NR_ANON_PAGES. NR_FILE_MAPPED is merely elaborating on the mapped
> subset of NR_FILE_PAGES, something which isn't necessary for anon
> pages as they're always mapped.

How strongly do you feel about reverting it as later patches would cause
lots of conflicts.

Obviously I found the new names clearer but I was thinking a lot at the
time about mapped vs unmapped due to looking closely at both reclaim and
[f|m]advise functions at the time. I found it mildly irksome to switch
between the semantics of file/anon when looking at the vmstat updates.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
