Date: Mon, 8 Nov 2004 16:56:49 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <Pine.LNX.4.58.0411080819260.8158@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Nov 2004, Christoph Lameter wrote:
> 
> Removing realtime statistics would remove lots of code from the vm.

Remove lots of code?  Adding lots nastier.

> Maintaining these counters requires locking which interferes with Nick's
> and my attempts to parallelize the vm.

Aren't you rather overestimating the importance of one single,
ideally atomic, increment per page fault?

It's great news if this is really the major scalability issue facing Linux.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
