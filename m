Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 744F76B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:04:44 -0400 (EDT)
Received: by wefh52 with SMTP id h52so3320122wef.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 16:04:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1337004860.2443.47.camel@twins>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
 <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de>
 <1337003515.2443.35.camel@twins> <alpine.DEB.2.00.1205140857380.26304@router.home>
 <1337004860.2443.47.camel@twins>
From: Roland Dreier <roland@kernel.org>
Date: Mon, 14 May 2012 16:04:22 -0700
Message-ID: <CAG4TOxOdBkdobs95EPvVNKEAk-S8A_Rs_Rdy3Ky+TTtS1sRukg@mail.gmail.com>
Subject: Re: Allow migration of mlocked page?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, May 14, 2012 at 7:14 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> Either that or a VMA flag, I think both infiniband and whatever new
> mlock API we invent will pretty much always be VMA wide. Or does the
> infinimuck take random pages out? All I really know about IB is to stay
> the #$%! away from it [as Mel recently learned the hard way] :-)

In general the InfiniBand pinning (calling get_user_pages()) is driven
by userspace, which doesn't really know anything about VMAs.

However userspace will often do madvise(DONT_FORK) on those
same ranges, so we'll probably have vma boundaries match up with
the ranges of pinned pages.

In any case I don't see any problem with doing vma splitting in
drivers/core/infiniband/umem.c if need be.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
