Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 765076B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 04:23:02 -0400 (EDT)
Date: Tue, 21 Apr 2009 09:23:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/25] Calculate the preferred zone for allocation only
	once
Message-ID: <20090421082318.GA12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-9-git-send-email-mel@csn.ul.ie> <20090421155256.F133.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421155256.F133.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 04:03:59PM +0900, KOSAKI Motohiro wrote:
> > get_page_from_freelist() can be called multiple times for an allocation.
> > Part of this calculates the preferred_zone which is the first usable
> > zone in the zonelist. This patch calculates preferred_zone once.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> I'm not sure this patch improve performance largely or not.
> but I don't find the bug.
> 

It's pretty small. In most cases, the preferred zone is going to be the
first one but in cases where it's not, this avoids walking the beginning
of the zonelist multiple times. How much time saved depends on the
number of times get_page_from_freelist() is called. It would be twice
for most of the systems early lifetime as the slower paths are not
entered but cost more when the system is lower on memory.

> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 

Thanks very much for these reviews.

> 
> 
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
