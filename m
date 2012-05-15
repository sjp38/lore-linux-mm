Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 9B4926B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:10:33 -0400 (EDT)
Date: Tue, 15 May 2012 09:10:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <CAHGf_=qW6759UUxPvzoLfTdPCOHAahxN9DsPkkXHgoij9e5urg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205150909380.6488@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de> <4FB08920.4010001@kernel.org> <20120514133944.GF29102@suse.de> <4FB1BC3E.3070107@kernel.org> <CAHGf_=qW6759UUxPvzoLfTdPCOHAahxN9DsPkkXHgoij9e5urg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

On Tue, 15 May 2012, KOSAKI Motohiro wrote:

> > 3. Many application already used mlock by semantic of 2. So let's break legacy application if possible.
>
> Many? really? I guess it's a very few.

They cannot have used the semantics since they never existed. Maybe the
application writers had certain assumptions about what mlock did but those
were wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
