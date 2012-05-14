Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 46FF36B00EA
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:09:15 -0400 (EDT)
Message-ID: <1337004537.2443.43.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 14 May 2012 16:08:57 +0200
In-Reply-To: <1337003515.2443.35.camel@twins>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
	 <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de>
	 <1337003515.2443.35.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>


Anyway, afaict there's only two options:

 1) make mlock() mean physically pinned (which we've so far always
rejected and isn't supported by whatever passes as a std for unix -- at
least not by the precise wording).

 2) keep mlock() to mean no major fault.

I strongly prefer 2 -- its what we've always said.


This might mean there's a need for a stronger API -- one that also
guarantees physically pinned. This is a more expensive
resource/operation. It means we need to migrate all memory to UNMOVABLE
blocks, possibly growing the number of such blocks with all the
down-sides that has.

Alternatively -- in case we pick 1 -- we should create a weaker variant
that does what mlock means now in order to allow people to not pressure
the system unduly.=20

I don't see any other way.. the current constraints really are mutually
exclusive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
