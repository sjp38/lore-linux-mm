Date: Sat, 6 Nov 2004 15:54:17 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <16781.12572.181444.967905@wombat.chubb.wattle.id.au>
Message-ID: <Pine.LNX.4.44.0411061553120.21150-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peter@chubb.wattle.id.au>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Nov 2004, Peter Chubb wrote:

> Is this going to scale properly to large machines, which usually have
> large numbers of active processes?  top is already
> almost unuseably slow on such machines; if all the pagetables have to
> be scanned to get RSS, it'll probably slow to a halt.

Not probably.  Certainly.

Christopher would do well to actually use his patch, while
running eg. an Oracle benchmark and using top to monitor
system activity.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
