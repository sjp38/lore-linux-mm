Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 5FE746B0070
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 18:43:43 -0500 (EST)
Date: Mon, 12 Nov 2012 23:43:41 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/8] Announcement: Enhanced NUMA scheduling with adaptive
 affinity
In-Reply-To: <20121112160451.189715188@chello.nl>
Message-ID: <0000013af701ca15-3acab23b-a16d-4e38-9dc0-efef05cbc5f2-000000@email.amazonses.com>
References: <20121112160451.189715188@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Mon, 12 Nov 2012, Peter Zijlstra wrote:

> The biggest conceptual addition, beyond the elimination of the home
> node, is that the scheduler is now able to recognize 'private' versus
> 'shared' pages, by carefully analyzing the pattern of how CPUs touch the
> working set pages. The scheduler automatically recognizes tasks that
> share memory with each other (and make dominant use of that memory) -
> versus tasks that allocate and use their working set privately.

That is a key distinction to make and if this really works then that is
major progress.

> This new scheduler code is then able to group tasks that are "memory
> related" via their memory access patterns together: in the NUMA context
> moving them on the same node if possible, and spreading them amongst
> nodes if they use private memory.

What happens if processes memory accesses  are related but the
common set of data does not fit into the memory provided by a single node?

The correct resolution usually is in that case to interleasve the pages
over both nodes in use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
