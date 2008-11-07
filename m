Date: Fri, 7 Nov 2008 10:42:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into pcp
Message-ID: <20081107104242.GC13786@csn.ul.ie>
References: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081106164644.GA14012@csn.ul.ie> <20081107104224.1631057e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081107104224.1631057e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 07, 2008 at 10:42:24AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 6 Nov 2008 16:46:45 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> > > otherwise, the system have unnecessary memory starvation risk
> > > because other cpu can't use this emergency pages.
> > > 
> > > 
> > > 
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > CC: Mel Gorman <mel@csn.ul.ie>
> > > CC: Christoph Lameter <cl@linux-foundation.org>
> > > 
> > 
> > This patch seems functionally sound but as Christoph points out, this
> > adds another branch to the fast path. Now, I ran some tests and those that
> > completed didn't show any problems but adding branches in the fast path can
> > eventually lead to hard-to-detect performance problems.
> > 
> dividing pcp-list into MIGRATE_TYPES is bad ?

I do not understand what your question is.

> If divided, we can get rid of scan. 
> 

I don't know what you are saying here either. I think you are saying
that we should avoid scanning the PCP lists for migrate types at all.
That hurts anti-fragmentation as pages can be badly placed if any pcp
page is used.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
