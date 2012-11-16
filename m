Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id AA7C56B002B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 15:57:32 -0500 (EST)
Date: Fri, 16 Nov 2012 20:57:31 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/8] Announcement: Enhanced NUMA scheduling with adaptive
 affinity
In-Reply-To: <20121116155943.GB4271@gmail.com>
Message-ID: <0000013b0b031a8f-e57805ad-a81f-4aa7-9906-ceb99f41210b-000000@email.amazonses.com>
References: <20121112160451.189715188@chello.nl> <0000013af701ca15-3acab23b-a16d-4e38-9dc0-efef05cbc5f2-000000@email.amazonses.com> <20121113072441.GA21386@gmail.com> <0000013b04769cf2-b57b16c0-5af0-4e7e-a736-e0aa2d4e4e78-000000@email.amazonses.com>
 <20121116155943.GB4271@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, 16 Nov 2012, Ingo Molnar wrote:

> > The interleaving of memory areas that have an equal amount of
> > shared accesses from multiple nodes is essential to limit the
> > traffic on the interconnect and get top performance.
>
> That is true only if the load is symmetric.

Which is usually true of an HPC workload.

> > I guess through that in a non HPC environment where you are
> > not interested in one specific load running at top speed
> > varying contention on the interconnect and memory busses are
> > acceptable. But this means that HPC loads cannot be auto
> > tuned.
>
> I'm not against improving these workloads (at all) - I just
> pointed out that interleaving isn't necessarily the best
> placement strategy for 'large' workloads.

Depends on what you mean by "large" workloads. If it is a typically large
HPC workload with data structures distributed over nodes then the
placement of those data structure spread over all nodes is the best
placement startegy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
