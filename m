Date: Mon, 8 Nov 2004 09:01:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0411080858400.8212@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Nov 2004, Hugh Dickins wrote:

> > Maintaining these counters requires locking which interferes with Nick's
> > and my attempts to parallelize the vm.
>
> Aren't you rather overestimating the importance of one single,
> ideally atomic, increment per page fault?

We would need to investigate that in detail. What we know is that if
multiple cpus do atomic increments with an additional spinlock/unlock etc
as done today then we do have a significant performance impact due to
exclusive cache lines oscillating between cpus.

> It's great news if this is really the major scalability issue facing Linux.

Not sure. This may just be a part of it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
