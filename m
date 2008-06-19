Date: Thu, 19 Jun 2008 08:38:09 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
	pte and _count=2?
Message-ID: <20080619133809.GC10123@sgi.com>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806191154270.7324@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806191154270.7324@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 19, 2008 at 12:09:15PM +0100, Hugh Dickins wrote:
> On Thu, 19 Jun 2008, Nick Piggin wrote:
> > On Thursday 19 June 2008 05:01, Hugh Dickins wrote:
> > > On Thu, 19 Jun 2008, Nick Piggin wrote:

> > We're talking about swap pages, as in do_swap_page? Then AFAIKS it
> > is only the mapcount that is taken into account, and get_user_pages
> > will first break COW, but that should set mapcount back to 1, in
> > which case the userspace access should notice that in do_swap_page
> > and prevent the 2nd COW from happening.
> 
> (I assume Robin is not forking, we do know that causes this kind
> of problem, but he didn't mention any forking so I assume not.)

There has been a fork long before this mapping was created.  There was a
hole at this location and the mapping gets established and pages populated
following all ranks of the MPI job getting initialized.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
