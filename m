Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9191A6B003D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 06:03:50 -0400 (EDT)
Date: Thu, 23 Apr 2009 11:03:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone
	watermark
Message-ID: <20090423100348.GA26953@csn.ul.ie>
References: <20090422171451.GG15367@csn.ul.ie> <1240422423.10627.96.camel@nimitz> <20090423092350.F6E6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090423092350.F6E6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 09:27:15AM +0900, KOSAKI Motohiro wrote:
> > On Wed, 2009-04-22 at 18:14 +0100, Mel Gorman wrote:
> > > Preference of taste really. When I started a conversion to accessors, it
> > > changed something recognised to something new that looked uglier to me.
> > > Only one place cares about the union enough to access is via an array so
> > > why spread it everywhere.
> > 
> > Personally, I'd say for consistency.  Someone looking at both forms
> > wouldn't necessarily know that they refer to the same variables unless
> > they know about the union.
> 
> for just clalification...
> 
> AFAIK, C language specification don't gurantee point same value.
> compiler can insert pad between struct-member and member, but not insert
> into array.
> 

Considering that they are the same type for elements and arrays, I
didn't think padding would ever be a problem.

> However, all gcc version don't do that. I think. but perhaps I missed
> some minor gcc release..
> 
> So, I also like Dave's idea. but it only personal feeling.
> 

The tide is against me on this one :).

How about I roll a patch on top of this set that replaces the union by
calling all sites? I figure that patch will go through a few revisions before
people are happy with the final API. However, as the patch wouldn't change
functionality, I'd like to see this series getting wider testing if possible. The
replace-union-with-single-array patch can be easily folded in then when
it settles.

Sound like a plan?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
