Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A08B46B01FA
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 10:57:27 -0400 (EDT)
Date: Fri, 16 Apr 2010 15:57:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] vmscan: simplify shrink_inactive_list()
Message-ID: <20100416145706.GK19264@csn.ul.ie>
References: <20100415085420.GT2493@dastard> <20100415185310.D1A1.A69D9226@jp.fujitsu.com> <20100415192140.D1A4.A69D9226@jp.fujitsu.com> <20100415131532.GD10966@csn.ul.ie> <87tyrc92un.fsf@basil.nowhere.org> <20100415154442.GG10966@csn.ul.ie> <20100415165416.GV18855@one.firstfloor.org> <20100415234013.GX2493@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100415234013.GX2493@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 09:40:13AM +1000, Dave Chinner wrote:
> On Thu, Apr 15, 2010 at 06:54:16PM +0200, Andi Kleen wrote:
> > > It's a buying-time venture, I'll agree but as both approaches are only
> > > about reducing stack stack they wouldn't be long-term solutions by your
> > > criteria. What do you suggest?
> > 
> > (from easy to more complicated):
> > 
> > - Disable direct reclaim with 4K stacks
> 
> Just to re-iterate: we're blowing the stack with direct reclaim on
> x86_64  w/ 8k stacks. 

Yep, that is not being disputed. By the way, what did you use to
generate your report? Was it CONFIG_DEBUG_STACK_USAGE or something else?
I used a modified bloat-o-meter to gather my data but it'd be nice to
be sure I'm seeing the same things as you (minus XFS unless I
specifically set it up).

> The old i386/4k stack problem is a red
> herring.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
