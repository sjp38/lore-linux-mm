Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 383416B01C6
	for <linux-mm@kvack.org>; Wed, 26 May 2010 06:23:50 -0400 (EDT)
Date: Wed, 26 May 2010 11:23:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/10] vmscan: move priority variable into scan_control
Message-ID: <20100526102330.GL29038@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-3-git-send-email-mel@csn.ul.ie> <20100416224820.GE20640@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100416224820.GE20640@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Sorry for the long delay on this. I got distracted by the anon_vma and
page migration stuff.

On Sat, Apr 17, 2010 at 12:48:20AM +0200, Johannes Weiner wrote:
> On Thu, Apr 15, 2010 at 06:21:35PM +0100, Mel Gorman wrote:
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > Now very lots function in vmscan have `priority' argument. It consume
> > stack slightly. To move it on struct scan_control reduce stack.
> 
> I don't like this much because it obfuscates value communication.
> 
> Functions no longer have obvious arguments and return values, as it's all
> passed hidden in that struct.
> 
> Do you think it's worth it?  I would much rather see that thing die than
> expand on it...

I don't feel strongly enough to fight about it and reducing stack usage here
isn't the "fix" anyway. I'll drop this patch for now.

That aside, the page reclaim algorithm maintains a lot of state and the
"priority" is part of that state. While the struct means that functions might
not have obvious arguments, passing the state around as arguments gets very
unwieldly very quickly. I don't think killing scan_control would be as
nice as you imagine although I do think it should be as small as
possible.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
