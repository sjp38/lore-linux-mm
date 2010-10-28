Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BAC028D0004
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 22:31:24 -0400 (EDT)
From: Ed Tomlinson <edt@aei.ca>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim condition
Date: Wed, 27 Oct 2010 22:31:07 -0400
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151341.31C3.A69D9226@jp.fujitsu.com> <20101027164138.GD29304@random.random>
In-Reply-To: <20101027164138.GD29304@random.random>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201010272231.08978.edt@aei.ca>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 27 October 2010 12:41:38 Andrea Arcangeli wrote:
> I hope lumpy work stops here and that it goes away whenever THP is
> merged.

Andrea,

I've been running THP here for since May (#25).  Here it does its job as it should.

When do you see it as ready for inclusion?

Thanks
Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
