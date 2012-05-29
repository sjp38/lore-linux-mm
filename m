Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id E7C596B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:57:13 -0400 (EDT)
Message-ID: <1338310613.26856.139.camel@twins>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 18:56:53 +0200
In-Reply-To: <4FC4FD51.2080001@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-14-git-send-email-aarcange@redhat.com>
	 <1338297385.26856.74.camel@twins> <20120529163849.GF21339@redhat.com>
	 <4FC4FD51.2080001@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, 2012-05-29 at 12:46 -0400, Rik van Riel wrote:
> > I don't think it's too great, memcg uses for half of that and yet
> > nobody is booting with cgroup_disable=3Dmemory even on not-NUMA servers
> > with less RAM.

Right, it was such a hit we had to disable that by default on RHEL6.

> Not any more.=20

Right, hnaz did great work there, but wasn't there still some few pieces
of the shadow page frame left? ISTR LSF/MM talk of moving the last few
bits into the regular page frame, taking the word that became available
through: fc9bb8c768 ("mm: Rearrange struct page").


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
