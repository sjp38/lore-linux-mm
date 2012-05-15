Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id DD9056B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 07:07:39 -0400 (EDT)
Message-ID: <1337080047.27694.37.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 15 May 2012 13:07:27 +0200
In-Reply-To: <4FB1B012.1090506@kernel.org>
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>
	  <4FB0866D.4020203@kernel.org> <1336978573.2443.13.camel@twins>
	 <4FB0B61E.6040902@kernel.org>
	 <alpine.DEB.2.00.1205140847340.26056@router.home>
	 <4FB1B012.1090506@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>

On Tue, 2012-05-15 at 10:23 +0900, Minchan Kim wrote:
> So many developers have been used it by meaning of "making sure latency".=
 :(

Many developers do many crazy things.. many use sched_yield() for
instance. Doesn't make it right though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
