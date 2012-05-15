Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A27AD6B0083
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:27:52 -0400 (EDT)
Date: Tue, 15 May 2012 09:27:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <CAG4TOxOdBkdobs95EPvVNKEAk-S8A_Rs_Rdy3Ky+TTtS1sRukg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205150922050.6488@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de> <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de> <1337003515.2443.35.camel@twins> <alpine.DEB.2.00.1205140857380.26304@router.home> <1337004860.2443.47.camel@twins>
 <CAG4TOxOdBkdobs95EPvVNKEAk-S8A_Rs_Rdy3Ky+TTtS1sRukg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, 14 May 2012, Roland Dreier wrote:

> In any case I don't see any problem with doing vma splitting in
> drivers/core/infiniband/umem.c if need be.

Prohibiting migration is already supported at the VMA level. There is no
need to add anyting extra.

"struct vm_operations_struct" has a field for the "migrate" function.
If that field is set to "fail_migrate_page" then no migration will ever
take place on the VMA.

But this feature is not accessible from user space. So far it has
only been used by special filesystesm.

And disabling migration does not solve the "I want no faults
whatsovever" requirement that I keep hearing.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
