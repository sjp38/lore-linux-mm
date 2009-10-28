Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9F86B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:57:03 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9SGqacC021854
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:52:36 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9SGuwQs1032408
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:56:58 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9SGuvih007544
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 12:56:57 -0400
Subject: Re: RFC: Transparent Hugepage support
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20091028163458.GT7744@basil.fritz.box>
References: <20091026185130.GC4868@random.random>
	 <87ljiwk8el.fsf@basil.nowhere.org> <20091027193007.GA6043@random.random>
	 <20091028042805.GJ7744@basil.fritz.box>
	 <20091028120050.GD9640@random.random>
	 <20091028141803.GQ7744@basil.fritz.box>
	 <20091028154827.GF9640@random.random>
	 <20091028160352.GS7744@basil.fritz.box>
	 <20091028162206.GG9640@random.random>
	 <20091028163458.GT7744@basil.fritz.box>
Content-Type: text/plain
Date: Wed, 28 Oct 2009 11:56:55 -0500
Message-Id: <1256749015.5613.31.camel@aglitke>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-10-28 at 17:34 +0100, Andi Kleen wrote:
> On Wed, Oct 28, 2009 at 05:22:06PM +0100, Andrea Arcangeli wrote:
> > I want to keep it as transparent as possible and to defer adding user
> > visible interfaces (with the exception of MADV_HUGEPAGE equivalent to
> > MADV_MERGEABLE for the scan daemon) initially. Even MADV_HUGEPAGE
> > might not be necessary, even the disable/enable global flag may not be
> > necessary but that is the absolute minimum tuning that seems
> > useful and so there's not much risk to obsolete it.
> 
> I think you need some user visible interfaces to cleanly handle existing
> reservations on a process base at least, otherwise you'll completely break 
> their semantics.

But we already handle explicit hugepages (with page pools and strict
reservations) via hugetlbfs and libhugetlbfs.  It seems you're just
making an argument for keeping these around (which I certainly agree
with).

> sysctls that change existing semantics greatly are usually a bad idea
> because what should the user do if they have existing applications
> that rely on old semantics, but still want the new functionality?

If you want to reserve some huge pages for a specific, corner-case
application, allocate huge pages the way we do today and use
libhugetlbfs.  Meanwhile, the rest of the system can benefit from this
new interface.

-- 
Thanks,
Adam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
