Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 206676B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 06:27:43 -0400 (EDT)
Date: Mon, 15 Jun 2009 11:28:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] Do not unconditionally treat zones that fail
	zone_reclaim() as full
Message-ID: <20090615102829.GC23198@csn.ul.ie>
References: <1244717273-15176-1-git-send-email-mel@csn.ul.ie> <1244717273-15176-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0906110948080.29827@gentwo.org> <20090612103617.GC14498@csn.ul.ie> <20090612084456.b6e4edb6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090612084456.b6e4edb6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 08:44:56AM -0700, Andrew Morton wrote:
> On Fri, 12 Jun 2009 11:36:17 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Thu, Jun 11, 2009 at 09:48:53AM -0400, Christoph Lameter wrote:
> > > It needs to be mentioned that this fixes a bug introduced in 2.6.19.
> > > Possibly a portion of this code needs to be backported to stable.
> > > 
> > 
> > Andrew has sucked up the patch already so I can't patch it. Andrew, there
> > is a further note below on the patch if you'd like to pick it up.
> 
> OK.
> 
> > On the stable front, I'm think that patches 1 and 2 should being considered
> > -stable candidates. Patch 1 is certainly needed because it fixes up the
> > malloc() stall and should be picked up by distro kernels as well. This patch
> > closes another obvious hole albeit one harder to trigger.
> > 
> > Ideally patch 3 would also be in -stable so distro kernels will suck it up
> > as it will help identify this problem in the field if it occurs again but
> > I'm not sure what the -stable policy is on such things are.
> 
> Well, I tagged the patches for stable but they don't apply at all well
> to even 2.6.30 base.
> 

What's the proper way to handle such a situation? Wait until the patches
go to mainline and post a rebased version to stable?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
