Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7070B6B0219
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:40:21 -0400 (EDT)
Date: Fri, 16 Apr 2010 09:40:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/4] vmscan: simplify shrink_inactive_list()
Message-ID: <20100415234013.GX2493@dastard>
References: <20100415085420.GT2493@dastard>
 <20100415185310.D1A1.A69D9226@jp.fujitsu.com>
 <20100415192140.D1A4.A69D9226@jp.fujitsu.com>
 <20100415131532.GD10966@csn.ul.ie>
 <87tyrc92un.fsf@basil.nowhere.org>
 <20100415154442.GG10966@csn.ul.ie>
 <20100415165416.GV18855@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415165416.GV18855@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 06:54:16PM +0200, Andi Kleen wrote:
> > It's a buying-time venture, I'll agree but as both approaches are only
> > about reducing stack stack they wouldn't be long-term solutions by your
> > criteria. What do you suggest?
> 
> (from easy to more complicated):
> 
> - Disable direct reclaim with 4K stacks

Just to re-iterate: we're blowing the stack with direct reclaim on
x86_64  w/ 8k stacks.  The old i386/4k stack problem is a red
herring.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
