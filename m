Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D56958D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 04:58:26 -0500 (EST)
Date: Tue, 16 Nov 2010 09:58:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] set_pgdat_percpu_threshold() don't use
	for_each_online_cpu
Message-ID: <20101116095809.GO27362@csn.ul.ie>
References: <1288169256-7174-2-git-send-email-mel@csn.ul.ie> <20101028100920.5d4ce413.kamezawa.hiroyu@jp.fujitsu.com> <20101114163727.BEE0.A69D9226@jp.fujitsu.com> <20101115102617.GK27362@csn.ul.ie> <alpine.DEB.2.00.1011150802470.19175@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011150802470.19175@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 08:04:23AM -0600, Christoph Lameter wrote:
> On Mon, 15 Nov 2010, Mel Gorman wrote:
> 
> > With recent per-cpu allocator changes, are we guaranteed that the per-cpu
> > structures exist and are valid?
> 
> We always guarantee that all per cpu areas for all possible cpus exist.
> That has always been the case. There was a discussion about changing
> that though. Could be difficult given the need for additional locking.
> 

In that case, I do not have any more concerns about the patch. It's
unfortunate that more per-cpu structures will have to be updated but I
doubt it'll be noticable.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
