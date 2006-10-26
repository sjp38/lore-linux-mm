Date: Thu, 26 Oct 2006 20:42:32 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 2/3] hugetlb: fix prio_tree unit
Message-ID: <20061026104232.GA7986@localhost.localdomain>
References: <Pine.LNX.4.64.0610250828020.8576@blonde.wat.veritas.com> <000001c6f890$373fb960$12d0180a@amr.corp.intel.com> <20061026034739.GA6046@localhost.localdomain> <Pine.LNX.4.64.0610260907390.6235@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610260907390.6235@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 26, 2006 at 09:13:28AM +0100, Hugh Dickins wrote:
> On Thu, 26 Oct 2006, David Gibson wrote:
> > +
> > +	/* This part of the test makes the problem more obvious, but
> > +	 * is not essential.  It can't be done on powerpc, where
> > +	 * segment restrictions prohibit us from performing such a
> > +	 * mapping, so skip it there */
> > +#if !defined(__powerpc__) && !defined(__powerpc64__)
> > +	/* Replace middle hpage by tinypage mapping to trigger
> > +	 * nr_ptes BUG */
> 
> I should add, I expect you'll need to extend that #if'ing to exclude
> at least ia64 too, won't you?   No architecture that segregates its
> hugepage virtual address space will manage the interposed tinypage.

Well, libhugetlbfs doesn't support ia64 at all, at present.  Mostly
just because none of us have convenient access to ia64 boxes to
develop or test on.

Porting will require a bunch of ugly switches to disable a third or
more of the functionality, though: the segment remapping stuff will
never work on ia64 in its present form either, again because of the
segregated address space.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
