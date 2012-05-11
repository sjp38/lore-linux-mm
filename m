Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A05D58D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:20:40 -0400 (EDT)
Message-ID: <1336728026.1017.7.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 11 May 2012 11:20:26 +0200
In-Reply-To: <4FAC9786.9060200@kernel.org>
References: <4FAC9786.9060200@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Fri, 2012-05-11 at 13:37 +0900, Minchan Kim wrote:
> I hope hear opinion from rt guys, too.

Its a problem yes, not sure your solution is any good though. As it
stands mlock() simply doesn't guarantee no faults, all it does is
guarantee no major faults.

Are you saying compaction doesn't actually move mlocked pages? I'm
somewhat surprised by that, I've always assumed it would.

Its sad that mlock() doesn't take a flags argument, so I'd rather
introduce a new madvise() flag for -rt, something like MADV_UNMOVABLE
(or whatever) which will basically copy the pages to an un-movable page
block and really pin the things.

That way mlock() can stay what the spec says it is and guarantee
residency.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
