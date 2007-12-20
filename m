Date: Wed, 19 Dec 2007 23:19:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
In-Reply-To: <200712191156.48507.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0712192317420.13118@schroedinger.engr.sgi.com>
References: <20071218211539.250334036@redhat.com> <20071218211550.186819416@redhat.com>
 <200712191156.48507.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Dec 2007, Nick Piggin wrote:

> These mlocked pages don't need to be on a non-reclaimable list,
> because we can find them again via the ptes when they become
> unlocked, and there is no point background scanning them, because
> they're always going to be locked while they're mlocked.

But there is something to be said for having a consistent scheme. Here we 
already introduce address space flags for one kind of unreclaimability. 
Isnt it possible to come up with a way to categorize pages that works 
(mostly) the same way for all types of pages with reclaim issues?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
