Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2B65C6B01F2
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 12:54:22 -0400 (EDT)
Date: Thu, 15 Apr 2010 18:54:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] vmscan: simplify shrink_inactive_list()
Message-ID: <20100415165416.GV18855@one.firstfloor.org>
References: <20100415085420.GT2493@dastard> <20100415185310.D1A1.A69D9226@jp.fujitsu.com> <20100415192140.D1A4.A69D9226@jp.fujitsu.com> <20100415131532.GD10966@csn.ul.ie> <87tyrc92un.fsf@basil.nowhere.org> <20100415154442.GG10966@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415154442.GG10966@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> It's a buying-time venture, I'll agree but as both approaches are only
> about reducing stack stack they wouldn't be long-term solutions by your
> criteria. What do you suggest?

(from easy to more complicated):

- Disable direct reclaim with 4K stacks
- Do direct reclaim only on separate stacks
- Add interrupt stacks to any 8K stack architectures.
- Get rid of 4K stacks completely
- Think about any other stackings that could give large scale recursion
and find ways to run them on separate stacks too.
- Long term: maybe we need 16K stacks at some point, depending on how
good the VM gets. Alternative would be to stop making Linux more complicated,
but that's unlikely to happen.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
