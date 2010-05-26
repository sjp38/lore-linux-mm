Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 76C116B01D4
	for <linux-mm@kvack.org>; Wed, 26 May 2010 07:22:04 -0400 (EDT)
Date: Wed, 26 May 2010 12:21:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 07/10] vmscan: Remove unnecessary temporary variables
	in shrink_zone()
Message-ID: <20100526112143.GM29038@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-8-git-send-email-mel@csn.ul.ie> <20100416115053.27A1.A69D9226@jp.fujitsu.com> <20100416230332.GH20640@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100416230332.GH20640@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2010 at 01:03:32AM +0200, Johannes Weiner wrote:
> On Fri, Apr 16, 2010 at 11:51:26AM +0900, KOSAKI Motohiro wrote:
> > > Two variables are declared that are unnecessary in shrink_zone() as they
> > > already exist int the scan_control. Remove them
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > ok.
> > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> You confuse me, you added the local variables yourself in 01dbe5c9
> for performance reasons.  Doesn't that still hold?
> 

To avoid a potential regression, I've dropped the patch.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
