Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC9B96B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:04:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so34631002wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:04:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d78si7331288wmi.121.2016.07.13.06.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:04:23 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:04:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 18/34] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160713130415.GB9905@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
 <20160712145801.GJ5881@cmpxchg.org>
 <20160713085516.GI9806@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160713085516.GI9806@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 09:55:16AM +0100, Mel Gorman wrote:
> On Tue, Jul 12, 2016 at 10:58:01AM -0400, Johannes Weiner wrote:
> > On Fri, Jul 08, 2016 at 10:34:54AM +0100, Mel Gorman wrote:
> > > NR_FILE_PAGES  is the number of        file pages.
> > > NR_FILE_MAPPED is the number of mapped file pages.
> > > NR_ANON_PAGES  is the number of mapped anon pages.
> > > 
> > > This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and
> > > NR_ANON_PAGES for mapped pages.  This patch renames NR_ANON_PAGES so we
> > > have
> > > 
> > > NR_FILE_PAGES  is the number of        file pages.
> > > NR_FILE_MAPPED is the number of mapped file pages.
> > > NR_ANON_MAPPED is the number of mapped anon pages.
> > 
> > That looks wrong to me. The symmetry is between NR_FILE_PAGES and
> > NR_ANON_PAGES. NR_FILE_MAPPED is merely elaborating on the mapped
> > subset of NR_FILE_PAGES, something which isn't necessary for anon
> > pages as they're always mapped.
> 
> How strongly do you feel about reverting it as later patches would cause
> lots of conflicts.
> 
> Obviously I found the new names clearer but I was thinking a lot at the
> time about mapped vs unmapped due to looking closely at both reclaim and
> [f|m]advise functions at the time. I found it mildly irksome to switch
> between the semantics of file/anon when looking at the vmstat updates.

I can see that. It all depends on whether you consider mapping state
or page type the more fundamental attribute, and coming from the
mapping perspective those new names make sense as well.

However, that leaves the disconnect between the enum name and what we
print to userspace. I find myself having to associate those quite a
lot to find all the sites that modify a given /proc/vmstat item, and
that's a bit of a pain if the names don't match.

I don't care strongly enough to cause a respin of half the series, and
it's not your problem that I waited until the last revision went into
mmots to review and comment. But if you agreed to a revert, would you
consider tacking on a revert patch at the end of the series?

Something like this?
