Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2026B01F7
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 10:34:22 -0400 (EDT)
Date: Fri, 14 Oct 2011 09:34:17 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <20111014141921.GC28592@sgi.com>
Message-ID: <alpine.DEB.2.00.1110140932530.6411@router.home>
References: <20111012120118.e948f40a.akpm@linux-foundation.org> <alpine.DEB.2.00.1110121452220.31218@router.home> <20111013152355.GB6966@sgi.com> <alpine.DEB.2.00.1110131052300.18473@router.home> <20111013135032.7c2c54cd.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1110131602020.26553@router.home> <20111013142434.4d05cbdc.akpm@linux-foundation.org> <20111014122506.GB26737@sgi.com> <20111014135055.GA28592@sgi.com> <alpine.DEB.2.00.1110140856420.6411@router.home> <20111014141921.GC28592@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Fri, 14 Oct 2011, Dimitri Sivanich wrote:

> Increasing the ZVC deltas (threshold value in calculate*threshold == 125)
> does -seem- to give a small speedup in this case (maybe as much as 50 MB/sec?).

Hmm... The question is how much do the VM paths used for the critical path
increment the vmstat counters on average per second? If we end up with
hundred of updates per second from each thread then we still have a
problem that can only be addressed by increasing the deltas beyond 125
meaning the fieldwidth must be increased to support 16 bit counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
