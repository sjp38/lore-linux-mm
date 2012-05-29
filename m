Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id DEE676B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:48:24 -0400 (EDT)
Message-ID: <1338313686.26856.164.camel@twins>
Subject: Re: [PATCH 08/35] autonuma: introduce kthread_bind_node()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 19:48:06 +0200
In-Reply-To: <20120529174423.GK21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-9-git-send-email-aarcange@redhat.com>
	 <1338295753.26856.60.camel@twins> <20120529161157.GE21339@redhat.com>
	 <1338311091.26856.146.camel@twins> <20120529174423.GK21339@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, 2012-05-29 at 19:44 +0200, Andrea Arcangeli wrote:
>=20
> But it'd be totally bad not to do the hard bindings to the cpu_s_ of
> the node, and not using PF_THREAD_BOUND would just allow userland to
> shoot itself in the foot. I mean if PF_THREAD_BOUND wouldn't exist
> already I wouldn't add it, but considering somebody bothered to
> implement it for the sake to make userland root user "safer", it'd be
> really silly not to take advantage of that for knuma_migrated too
> (even if it binds to more than 1 CPU).=20

No, I'm absolutely ok with the user shooting himself in the foot. The
thing exists because you can crash stuff if you get it wrong with
per-cpu.

Crashing is not good, worse performance is his own damn fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
