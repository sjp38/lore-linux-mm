Date: Wed, 19 Dec 2007 08:45:34 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Message-ID: <20071219084534.4fee8718@bree.surriel.com>
In-Reply-To: <200712191156.48507.nickpiggin@yahoo.com.au>
References: <20071218211539.250334036@redhat.com>
	<20071218211550.186819416@redhat.com>
	<200712191156.48507.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Dec 2007 11:56:48 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Wednesday 19 December 2007 08:15, Rik van Riel wrote:
> 
> > Rework of a patch by Nick Piggin -- part 1 of 2.
> >
> > This patch:
> >
> > 1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
> >    stub version of the mlock/noreclaim APIs when it's
> >    not configured.  Depends on [CONFIG_]NORECLAIM.

> Hmm, I still don't know (or forgot) why you don't just use the
> old scheme of having an mlock count in the LRU bit, and removing
> the mlocked page from the LRU completely.

How do we detect those pages reliably in the lumpy reclaim code?
 
> These mlocked pages don't need to be on a non-reclaimable list,
> because we can find them again via the ptes when they become
> unlocked, and there is no point background scanning them, because
> they're always going to be locked while they're mlocked.

Agreed.

The main reason I sent out these patches now is that I just
wanted to get some comments from other upstream developers.

I have gotten distracted by other work so much that I spent
most of my time forward porting the patch set, and not enough
time working with the rest of the upstream community to get
the code moving forward.

To be honest, I have only briefly looked at the non-reclaimable
code.  I would be more than happy to merge any improvements to
that code.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
