Date: Fri, 17 Oct 2008 13:17:17 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: no way to swapoff a deleted swap file?
In-Reply-To: <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org>
Message-ID: <Pine.LNX.4.64.0810171250410.22374@blonde.site>
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it>
 <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it>
 <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bodo Eggert <7eggert@gmx.de>
Cc: David Newall <davidn@davidnewall.com>, Peter Zijlstra <peterz@infradead.org>, Peter Cordes <peter@cordes.ca>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2008, Bodo Eggert wrote:
> 
> Somebody might want their swapfiles to have zero links,
> _and_ the possibility of doing swapoff.

You're right, they might, and it's not an unreasonable wish.
But we've not supported it in the past, and I still don't
think it's worth adding special kernel support for it now.

> If you can do it by keeping some fds open to let
> /proc/pid/fd point to the files, I think it's OK.

I've a very strong aversion to adding strange code to abuse the
/proc/<pid>/fd space of some random kernel thread - a "kswapd"
because its name contains the substring "swap"?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
