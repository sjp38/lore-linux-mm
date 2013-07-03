Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 0B9EE6B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 14:35:52 -0400 (EDT)
Date: Wed, 3 Jul 2013 20:35:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 12/13] mm: numa: Scan pages with elevated page_mapcount
Message-ID: <20130703183517.GC18898@dyad.programming.kicks-ass.net>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-13-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372861300-9973-13-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 03:21:39PM +0100, Mel Gorman wrote:
> Initial support for automatic NUMA balancing was unable to distinguish
> between false shared versus private pages except by ignoring pages with an
> elevated page_mapcount entirely. This patch kicks away the training wheels
> as initial support for identifying shared/private pages is now in place.
> Note that the patch still leaves shared, file-backed in VM_EXEC vmas in
> place guessing that these are shared library pages. Migrating them are
> likely to be of major benefit as generally the expectation would be that
> these are read-shared between caches and that iTLB and iCache pressure is
> generally low.

This reminds me; there a clause in task_numa_work() that skips 'small' VMAs. I
don't see the point of that.

In fact; when using things like electric fence this might mean skipping most
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
