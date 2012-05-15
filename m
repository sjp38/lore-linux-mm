Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 50A4E6B00EA
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:36:25 -0400 (EDT)
Date: Tue, 15 May 2012 09:09:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <4FB1BC3E.3070107@kernel.org>
Message-ID: <alpine.DEB.2.00.1205150908200.6488@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de> <4FB08920.4010001@kernel.org> <20120514133944.GF29102@suse.de> <4FB1BC3E.3070107@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

On Tue, 15 May 2012, Minchan Kim wrote:

> One of clear point is that it's okay to migrate mlocked page in CMA.
> And we can migrate mlocked anonymous pages and mlocked file pages by MIGRATE_ASYNC mode in compaction
> if we all agree Peter who says "mlocked mean NO MAJOR FAULT".

As far as I can recall the posix definiton mlocked means the page stays in
memory and is not evicted. It says nothing about faults.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
