Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CDB9A6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 05:14:19 -0500 (EST)
Date: Fri, 11 Nov 2011 10:14:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111111101414.GJ3083@suse.de>
References: <20111110100616.GD3083@suse.de>
 <20111110142202.GE3083@suse.de>
 <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
 <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 10, 2011 at 03:37:32PM -0800, David Rientjes wrote:
> On Thu, 10 Nov 2011, Andrew Morton wrote:
> 
> > > This patch once again prevents sync migration for transparent
> > > hugepage allocations as it is preferable to fail a THP allocation
> > > than stall.
> > 
> > Who said?  ;) Presumably some people would prefer to get lots of
> > huge pages for their 1000-hour compute job, and waiting a bit to get
> > those pages is acceptable.
> > 
> 
> Indeed.  It seems like the behavior would better be controlled with 
> /sys/kernel/mm/transparent_hugepage/defrag which is set aside specifically 
> to control defragmentation for transparent hugepages and for that 
> synchronous compaction should certainly apply.

With khugepaged in place, it's adding a tunable that is unnecessary and
will not be used. Even if such a tuneable was created, the default
behaviour should be "do not stall".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
