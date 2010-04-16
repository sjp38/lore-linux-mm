Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B5D116B01E3
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 05:40:07 -0400 (EDT)
Date: Fri, 16 Apr 2010 10:39:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] vmscan: simplify shrink_inactive_list()
Message-ID: <20100416093943.GA19264@csn.ul.ie>
References: <20100415085420.GT2493@dastard> <20100415185310.D1A1.A69D9226@jp.fujitsu.com> <20100415192140.D1A4.A69D9226@jp.fujitsu.com> <20100415131532.GD10966@csn.ul.ie> <16363.1271355721@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <16363.1271355721@localhost>
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 02:22:01PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 15 Apr 2010 14:15:33 BST, Mel Gorman said:
> 
> > Yep. I modified bloat-o-meter to work with stacks (imaginatively calling it
> > stack-o-meter) and got the following. The prereq patches are from
> > earlier in the thread with the subjects
> 
> Think that's a script worth having in-tree?

Ahh, it's a hatchet-job at the moment. I copied bloat-o-meter and
altered one function. I made a TODO note to extend bloat-o-meter
properly and that would be worth merging.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
