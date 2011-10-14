Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 148FD6B01F0
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 09:57:20 -0400 (EDT)
Date: Fri, 14 Oct 2011 08:57:16 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <20111014135055.GA28592@sgi.com>
Message-ID: <alpine.DEB.2.00.1110140856420.6411@router.home>
References: <20111012160202.GA18666@sgi.com> <20111012120118.e948f40a.akpm@linux-foundation.org> <alpine.DEB.2.00.1110121452220.31218@router.home> <20111013152355.GB6966@sgi.com> <alpine.DEB.2.00.1110131052300.18473@router.home> <20111013135032.7c2c54cd.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1110131602020.26553@router.home> <20111013142434.4d05cbdc.akpm@linux-foundation.org> <20111014122506.GB26737@sgi.com> <20111014135055.GA28592@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Fri, 14 Oct 2011, Dimitri Sivanich wrote:

> Testing on a smaller machine with 46 writer threads in parallel (my original
> test used 120).
>
> Looks as though cache-aligning and padding the end of the vm_stat array
> results in a ~150 MB/sec speedup.  This is a nice improvement for only 46
> writer threads, though it's not the full ~250 MB/sec speedup I get from
> setting OVERCOMMIT_NEVER.

Add to this the increase in the deltas for the ZVCs and change the stat
interval to 10 sec?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
