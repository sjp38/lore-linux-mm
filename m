Date: Fri, 14 Nov 2008 12:34:22 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.28?] don't unlink an active swapfile
Message-ID: <20081114173422.GA22868@infradead.org>
References: <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it> <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org> <Pine.LNX.4.64.0810171250410.22374@blonde.site> <20081018003117.GC26067@cordes.ca> <20081018051800.GO24654@1wt.eu> <Pine.LNX.4.64.0810182058120.7154@blonde.site> <20081018204948.GA22140@infradead.org> <20081018205647.GA29946@1wt.eu> <Pine.LNX.4.64.0811140234300.5027@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811140234300.5027@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Christoph Hellwig <hch@infradead.org>, Peter Cordes <peter@cordes.ca>, Bodo Eggert <7eggert@gmx.de>, David Newall <davidn@davidnewall.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 14, 2008 at 02:37:22AM +0000, Hugh Dickins wrote:
> Peter Cordes is sorry that he rm'ed his swapfiles while they were in use,
> he then had no pathname to swapoff.  It's a curious little oversight, but
> not one worth a lot of hackery.  Kudos to Willy Tarreau for turning this
> around from a discussion of synthetic pathnames to how to prevent unlink.
> Mimic immutable: prohibit unlinking an active swapfile in may_delete()
> (and don't worry my little head over the tiny race window).

Looks good (but I think I already said this before)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
