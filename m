Date: Mon, 19 Jun 2000 23:46:27 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: shrink_mmap() change in ac-21
Message-ID: <20000619234627.B23135@pcep-jamie.cern.ch>
References: <87r99t8m2r.fsf@atlas.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87r99t8m2r.fsf@atlas.iskon.hr>; from zlatko@iskon.hr on Mon, Jun 19, 2000 at 10:14:52PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Zlatko Calusic wrote:
> The shrink_mmap() change in your latest prepatch (ac12) doesn't look
> very healthy. Removing the test for the wrong zone we effectively
> discard lots of wrong pages before we get to the right one. That is
> effectively flushing the page cache and we have unbalanced system.

You know, there may be some sense in removing pages from the wrong zone,
if those wrong zones are quite full.  If the DMA zone desparately needs
free pages and keeps needing them, isn't it good to encourage future
non-DMA allocations to use another zone?  Removing pages from other
zones is one way to achieve that.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
