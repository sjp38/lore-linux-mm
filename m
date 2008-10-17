Date: Sat, 18 Oct 2008 00:42:41 +0200 (CEST)
From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: no way to swapoff a deleted swap file?
In-Reply-To: <Pine.LNX.4.64.0810171250410.22374@blonde.site>
Message-ID: <alpine.LSU.0.999.0810180032380.13874@be1.lrz>
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it>
 <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it>
 <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org>
 <Pine.LNX.4.64.0810171250410.22374@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Bodo Eggert <7eggert@gmx.de>, David Newall <davidn@davidnewall.com>, Peter Zijlstra <peterz@infradead.org>, Peter Cordes <peter@cordes.ca>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2008, Hugh Dickins wrote:
> On Fri, 17 Oct 2008, Bodo Eggert wrote:

> > Somebody might want their swapfiles to have zero links,
> > _and_ the possibility of doing swapoff.
> 
> You're right, they might, and it's not an unreasonable wish.
> But we've not supported it in the past, and I still don't
> think it's worth adding special kernel support for it now.

IMO it depends on the cost. Maybe it's cheap to keep an extra fd around, 
maybe you'd have to add an extra infrastructure for this. And maybe it's not 
important enough for anybody to create a patch and let us know ...
-- 
Funny quotes:
9. Despite the cost of living, have you noticed how popular it remains?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
