Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C7A9F6B00CA
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 11:23:22 -0400 (EDT)
Date: Thu, 28 Oct 2010 17:22:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim
 condition
Message-ID: <20101028152246.GO29304@random.random>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151341.31C3.A69D9226@jp.fujitsu.com>
 <20101027164138.GD29304@random.random>
 <201010272231.08978.edt@aei.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201010272231.08978.edt@aei.ca>
Sender: owner-linux-mm@kvack.org
To: Ed Tomlinson <edt@aei.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Oct 27, 2010 at 10:31:07PM -0400, Ed Tomlinson wrote:
> On Wednesday 27 October 2010 12:41:38 Andrea Arcangeli wrote:
> > I hope lumpy work stops here and that it goes away whenever THP is
> > merged.
> 
> Andrea,
> 
> I've been running THP here for since May (#25).  Here it does its job as it should.

Thanks for the report :).

> When do you see it as ready for inclusion?

It is already ready for inclusion. I posted it on 24 Oct to Linus but
got no answer. I guess he's being busy with merging the other stuff
(including the lumpy improvements that now requires me to remove more
stuff, but that's not big deal, but I'll have to audit everything and
separate the good from the bad and identify any real fix from the
lumpy stuff that I'll drop, I'll drop also removing the vmstat.h
lumpy stats, so some userland rebuild may be needed).

As long as sc->lumpy_reclaim_mode is always = LUMPY_MODE_NONE,
whenever sc->order == 0, I'm not going to let it live in my tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
