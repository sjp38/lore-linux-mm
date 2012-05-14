Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 476736B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 03:45:11 -0400 (EDT)
Message-ID: <1336981501.2443.19.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 14 May 2012 09:45:01 +0200
In-Reply-To: <4FB0B61E.6040902@kernel.org>
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>
	  <4FB0866D.4020203@kernel.org> <1336978573.2443.13.camel@twins>
	 <4FB0B61E.6040902@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, 2012-05-14 at 16:37 +0900, Minchan Kim wrote:
> What's the meaning of "locked"? Isn't it pinning?

It doesn't say, the best inference I can make is that locked means the
effect of mlock() which is defined as: 'to be memory-resident', esp. so
since it then states: 'until unlocked' (or exit/exec).

So basically the statement: 'locked and memory-resident' is redundant.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
