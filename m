Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id AD4CA6B00EB
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:45:26 -0400 (EDT)
Message-ID: <1337093115.27694.51.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 15 May 2012 16:45:15 +0200
In-Reply-To: <alpine.DEB.2.00.1205150911140.6488@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
	 <4FB08920.4010001@kernel.org> <20120514133944.GF29102@suse.de>
	 <4FB1BC3E.3070107@kernel.org>
	 <CAHGf_=qW6759UUxPvzoLfTdPCOHAahxN9DsPkkXHgoij9e5urg@mail.gmail.com>
	 <1337079974.27694.36.camel@twins>
	 <alpine.DEB.2.00.1205150911140.6488@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Tue, 2012-05-15 at 09:12 -0500, Christoph Lameter wrote:
> On Tue, 15 May 2012, Peter Zijlstra wrote:
>=20
> > So yes, page migration is a 'serious' problem, but only because the way
> > its implemented is sub-optimal.
>=20
> For the low-latency cases: page migration needs to be restricted to cpus
> that are allowed to run high latency tasks or restricted to a time that n=
o
> low-latency responses are needed by the app. This means during setup or
> special processing times (maybe after some action was completed).
>=20
> A random compaction run can be very bad for a latency critical section.

Yes however:

 1) low latency doesn't make real-time, time bounds do.
 2) the latency impact of migration can be _MUCH_ improved if someone
were to care about it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
