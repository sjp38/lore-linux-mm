Date: Tue, 19 Feb 2002 00:03:33 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <E16cxgg-0000xa-00@starship.berlin>
Message-ID: <Pine.LNX.4.21.0202182358190.1021-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, Rik van Riel <riel@conectiva.com.br>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2002, Daniel Phillips wrote:
> On February 18, 2002 08:04 pm, Hugh Dickins wrote:
> > On Mon, 18 Feb 2002, Daniel Phillips wrote:
> > > On February 18, 2002 09:09 am, Hugh Dickins wrote:
> > > > Since copy_page_range would not copy shared page tables, I'm wrong to
> > > > point there.  But __pte_alloc does copy shared page tables (to unshare
> > > > them), and needs them to be stable while it does so: so locking against
> > > > swap_out really is required.  It also needs locking against read faults,
> > > > and they against each other: but there I imagine it's just a matter of
> > > > dropping the write arg to __pte_alloc, going back to pte_alloc again.
> 
> I'm not sure what you mean here, you're not suggesting we should unshare the
> page table on read fault are you?

I am.  But I can understand that you'd prefer not to do it that way.
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
