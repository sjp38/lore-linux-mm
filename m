Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 633136B00F0
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:14:27 -0400 (EDT)
Message-ID: <1337004860.2443.47.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 14 May 2012 16:14:20 +0200
In-Reply-To: <alpine.DEB.2.00.1205140857380.26304@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
	 <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de>
	 <1337003515.2443.35.camel@twins>
	 <alpine.DEB.2.00.1205140857380.26304@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>, roland@kernel.org

On Mon, 2012-05-14 at 09:01 -0500, Christoph Lameter wrote:
> On Mon, 14 May 2012, Peter Zijlstra wrote:
>=20
> > I'd say go for it, I've been telling everybody who would listen that
> > mlock() only means no major faults for a very long time now.
>=20
> We could introduce a new page flag PG_pinned (it already exists for Xen)
> that would mean no faults on the page?
>=20
> The situation with pinned pages is not clean right now because page count
> increases should only signal temporary references to a page but subsystem=
s
> use an elevated page count to pin pages for good (f.e. Infiniband memory
> registration). The reclaim logic has no way to differentiate between a
> pinned page and a temporary reference count increase for page handling.
>=20
> Therefore f.e. the page migration logic will repeatedly try to move the
> page and always fail to account for all references.
>=20
> A PG_pinned could allow us to make that distinction to avoid overhead in
> the reclaim and page migration logic and also we could add some semantics
> that avoid page faults.

Either that or a VMA flag, I think both infiniband and whatever new
mlock API we invent will pretty much always be VMA wide. Or does the
infinimuck take random pages out? All I really know about IB is to stay
the #$%! away from it [as Mel recently learned the hard way] :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
