Date: Thu, 20 Dec 2007 10:33:32 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Message-ID: <20071220103332.11c4bbd2@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0712192317420.13118@schroedinger.engr.sgi.com>
References: <20071218211539.250334036@redhat.com>
	<20071218211550.186819416@redhat.com>
	<200712191156.48507.nickpiggin@yahoo.com.au>
	<Pine.LNX.4.64.0712192317420.13118@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Dec 2007 23:19:00 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 19 Dec 2007, Nick Piggin wrote:
> 
> > These mlocked pages don't need to be on a non-reclaimable list,
> > because we can find them again via the ptes when they become
> > unlocked, and there is no point background scanning them, because
> > they're always going to be locked while they're mlocked.
> 
> But there is something to be said for having a consistent scheme. 

The code as called from .c files should indeed be consistent.

However, since we never need to scan the non-reclaimable list,
we could use the inline functions in the .h files to have an
mlock count instead of a .lru list head in the non-reclaimable
pages.

At least, I think so.  I'm going to have to think about the
details a lot more.  I have no idea yet if there will be any
impact from batching the pages on pagevecs, vs. an atomic
mlock count...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
