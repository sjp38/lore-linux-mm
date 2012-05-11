Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2DC358D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 12:20:49 -0400 (EDT)
Date: Fri, 11 May 2012 11:20:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <1336728026.1017.7.camel@twins>
Message-ID: <alpine.DEB.2.00.1205111117380.31049@router.home>
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Fri, 11 May 2012, Peter Zijlstra wrote:

> On Fri, 2012-05-11 at 13:37 +0900, Minchan Kim wrote:
> > I hope hear opinion from rt guys, too.
>
> Its a problem yes, not sure your solution is any good though. As it
> stands mlock() simply doesn't guarantee no faults, all it does is
> guarantee no major faults.

There are two different way to lock pages down in memory that have
different counters in /proc/<pid>/status and also different semantics.

VmLck: Mlocked pages. This means there is a prohibition against evicting
pages. These pages can undergo page migration and therefore also be
handled by compation. These pages have PG_mlock set.

VmPin: Pinned pages. Page cannot be moved. These pages have an elevated
refcount that makes page migration fail.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
