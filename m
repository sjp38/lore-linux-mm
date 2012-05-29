Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C26D46B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 10:54:31 -0400 (EDT)
Message-ID: <1338303251.26856.94.camel@twins>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 16:54:11 +0200
In-Reply-To: <4FC4D58A.50800@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	  <1337965359-29725-14-git-send-email-aarcange@redhat.com>
	 <1338297385.26856.74.camel@twins> <4FC4D58A.50800@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, 2012-05-29 at 09:56 -0400, Rik van Riel wrote:
> On 05/29/2012 09:16 AM, Peter Zijlstra wrote:
> > On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
>=20
> > 24 bytes per page.. or ~0.6% of memory gone. This is far too great a
> > price to pay.
> >
> > At LSF/MM Rik already suggested you limit the number of pages that can
> > be migrated concurrently and use this to move the extra list_head out o=
f
> > struct page and into a smaller amount of extra structures, reducing the
> > total overhead.
>=20
> For THP, we should be able to track this NUMA info on a
> 2MB page granularity.

Yeah, but that's another x86-only feature, _IF_ we're going to do this
it must be done for all archs that have CONFIG_NUMA, thus we're stuck
with 4k (or other base page size).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
