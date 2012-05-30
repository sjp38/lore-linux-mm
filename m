Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 7A6EE6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:55:54 -0400 (EDT)
Message-ID: <1338371727.26856.234.camel@twins>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 30 May 2012 11:55:27 +0200
In-Reply-To: <4FC5EB3C.7040505@gmail.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	    <1337965359-29725-14-git-send-email-aarcange@redhat.com>
	   <1338297385.26856.74.camel@twins> <4FC4D58A.50800@redhat.com>
	  <1338303251.26856.94.camel@twins> <4FC5D973.3080108@gmail.com>
	 <1338368763.26856.207.camel@twins> <4FC5EB3C.7040505@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Wed, 2012-05-30 at 05:41 -0400, KOSAKI Motohiro wrote:
> > Yes, and we all know objects allocated in one thread are never shared
> > with other threads.. the producer-consumer pattern seems fairly popular
> > and will destroy your argument.
>=20
> THP also strike producer-consumer pattern. But, as far as I know, people =
haven't observed
> significant performance degression. thus I _guessed_ performance critical=
 producer-consumer
> pattern is rare. Just guess.=20

Not so, as long as the areas span PMDs THP can back them using huge
pages, regardless of what objects live in that virtual space (or indeed
if its given out as objects at all or lives on the free-lists).

THP doesn't care about what lives in the virtual space, all it cares
about is ranges spanning PMDs that are populated densely enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
