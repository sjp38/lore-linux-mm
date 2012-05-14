Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id F41F16B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 11:06:24 -0400 (EDT)
Date: Mon, 14 May 2012 09:43:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <1337004860.2443.47.camel@twins>
Message-ID: <alpine.DEB.2.00.1205140940550.26304@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de> <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de> <1337003515.2443.35.camel@twins> <alpine.DEB.2.00.1205140857380.26304@router.home> <1337004860.2443.47.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>, roland@kernel.org

On Mon, 14 May 2012, Peter Zijlstra wrote:

> > A PG_pinned could allow us to make that distinction to avoid overhead in
> > the reclaim and page migration logic and also we could add some semantics
> > that avoid page faults.
>
> Either that or a VMA flag, I think both infiniband and whatever new
> mlock API we invent will pretty much always be VMA wide. Or does the
> infinimuck take random pages out? All I really know about IB is to stay
> the #$%! away from it [as Mel recently learned the hard way] :-)

Devices (also infiniband) register buffers allocated on the heap and
increase the page count of the pages. Its not VMA bound.

Creating a VMA flag would force device driver writers to break up VMAs I
think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
