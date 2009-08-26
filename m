Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 245ED6B015F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:08:06 -0400 (EDT)
Date: Wed, 26 Aug 2009 12:08:09 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: VM issue causing high CPU loads
Message-ID: <20090826110809.GG10955@csn.ul.ie>
References: <4A92A25A.4050608@yohan.staff.proxad.net> <20090824162155.ce323f08.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090824162155.ce323f08.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yohan <kernel@yohan.staff.proxad.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 04:21:55PM -0700, Andrew Morton wrote:
> On Mon, 24 Aug 2009 16:23:22 +0200
> Yohan <kernel@yohan.staff.proxad.net> wrote:
> 
> > Hi,
> > 
> >     Is someone have an idea for that :
> > 
> >         http://bugzilla.kernel.org/show_bug.cgi?id=14024
> > 
> 
> Please generate a kernel profile to work out where all the CPU tie is
> being spent.  Documentation/basic_profiling.txt is a starting point.
> 

In the absense of a profile, here is a total stab in the dark. Is this a
NUMA machine? If so, is /proc/sys/vm/zone_reclaim_mode set to 1 and does
setting it to 0 help?

This is based on a relatively recent bug where malloc() could stall for
long times with large amounts of CPU usage due to useless scanning in
page reclaim.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
