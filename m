Date: Tue, 1 Jul 2003 12:01:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: What to expect with the 2.6 VM
In-Reply-To: <20030630200237.473d5f82.akpm@digeo.com>
Message-ID: <Pine.LNX.4.44.0307011147460.1161-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Andrea Arcangeli <andrea@suse.de>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jun 2003, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> > 
> > described this way it sounds like NOFAIL imply a deadlock condition.
> 
> NOFAIL is what 2.4 has always done, and has the deadlock opportunities
> which you mention.  The other modes allow the caller to say "don't try
> forever".

__GFP_NOFAIL is also very badly named: patently it can and does fail,
when PF_MEMALLOC or PF_MEMDIE or not __GFP_WAIT.  Or is the idea that
its users might as well oops when it does fail?  Should its users be
changed to use the less perniciously named __GFP_REPEAT, or should
__alloc_pages be changed to deadlock more thoroughly?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
