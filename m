Subject: Re: [PATCH] mm: inactive-clean list
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0607172035140.28956@schroedinger.engr.sgi.com>
References: <1153167857.31891.78.camel@lappy>
	 <Pine.LNX.4.64.0607172035140.28956@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 18 Jul 2006 14:16:35 +0200
Message-Id: <1153224998.2041.15.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-07-17 at 20:37 -0700, Christoph Lameter wrote:
> On Mon, 17 Jul 2006, Peter Zijlstra wrote:
> 
> > This patch implements the inactive_clean list spoken of during the VM summit.
> > The LRU tail pages will be unmapped and ready to free, but not freeed.
> > This gives reclaim an extra chance.
> 
> I thought we wanted to just track the number of unmapped clean pages and 
> insure that they do not go under a certain limit? That would not require
> any locking changes but just a new zoned counter and a check in the dirty
> handling path.

The problem I see with that is that we cannot create new unmapped clean
pages. Where will we get new pages to satisfy our demand when there is
nothing mmap'ed.

This approach will generate them by forceing some pages into swap space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
