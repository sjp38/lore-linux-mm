Date: Sat, 6 Nov 2004 15:51:41 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.44.0411061550220.21150-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Christoph Lameter wrote:

> Doing a ps is not a frequent event. Of course this may cause
> significant load if one does regularly access /proc entities then. Are
> there any threads from the past with some numbers of what the impact was
> when we calculated rss via proc?

Running top(1) on stock 2.4 kernels pretty much kills large
systems from SGI and IBM.  Think about walking the VM for
10,000 processes, with 3GB virtual memory each, every 3
seconds.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
