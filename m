Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE346B00ED
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 07:24:34 -0400 (EDT)
Date: Thu, 18 Mar 2010 11:24:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/11] Allow CONFIG_MIGRATION to be set without
	CONFIG_NUMA or memory hot-remove
Message-ID: <20100318112414.GL12388@csn.ul.ie>
References: <20100317113205.GC12388@csn.ul.ie> <alpine.DEB.2.00.1003171135390.27268@router.home> <20100318085226.8726.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100318085226.8726.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 18, 2010 at 08:56:23AM +0900, KOSAKI Motohiro wrote:
> > On Wed, 17 Mar 2010, Mel Gorman wrote:
> > 
> > > > If select MIGRATION works, we can remove "depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE"
> > > > line from config MIGRATION.
> > > >
> > >
> > > I'm not quite getting why this would be an advantage. COMPACTION
> > > requires MIGRATION but conceivable both NUMA and HOTREMOVE can work
> > > without it.
> > 
> > Avoids having to add additional CONFIG_XXX on the page migration "depends"
> > line in the future.
> 
> Yes, Kconfig mess freqently shot ourself in past days. if we have a chance
> to remove unnecessary dependency, we should do. that's my intention of the last mail.
> 

But if the depends line is removed, it could be set without NUMA, memory
hot-remove or compaction enabled. That wouldn't be very useful. I'm
missing something obvious.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
