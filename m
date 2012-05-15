Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id DBB9B6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:12:41 -0400 (EDT)
Date: Tue, 15 May 2012 09:12:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <1337079974.27694.36.camel@twins>
Message-ID: <alpine.DEB.2.00.1205150911140.6488@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de> <4FB08920.4010001@kernel.org> <20120514133944.GF29102@suse.de> <4FB1BC3E.3070107@kernel.org> <CAHGf_=qW6759UUxPvzoLfTdPCOHAahxN9DsPkkXHgoij9e5urg@mail.gmail.com>
 <1337079974.27694.36.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Tue, 15 May 2012, Peter Zijlstra wrote:

> So yes, page migration is a 'serious' problem, but only because the way
> its implemented is sub-optimal.

For the low-latency cases: page migration needs to be restricted to cpus
that are allowed to run high latency tasks or restricted to a time that no
low-latency responses are needed by the app. This means during setup or
special processing times (maybe after some action was completed).

A random compaction run can be very bad for a latency critical section.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
