Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 808DB6B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 09:10:33 -0400 (EDT)
Message-ID: <1338297004.26856.70.camel@twins>
Subject: Re: [PATCH 12/35] autonuma: CPU follow memory algorithm
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 15:10:04 +0200
In-Reply-To: <1337965359-29725-13-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-13-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> + * This function is responsible for deciding which is the best CPU
> + * each process should be running on according to the NUMA
> + * affinity. To do that it evaluates all CPUs and checks if there's
> + * any remote CPU where the current process has more NUMA affinity
> + * than with the current CPU, and where the process running on the
> + * remote CPU has less NUMA affinity than the current process to run
> + * on the remote CPU. Ideally this should be expanded to take all
> + * runnable processes into account but this is a good
> + * approximation. When we compare the NUMA affinity between the
> + * current and remote CPU we use the per-thread information if the
> + * remote CPU runs a thread of the same process that the current task
> + * belongs to, or the per-process information if the remote CPU runs
> a
> + * different process than the current one. If the remote CPU runs the
> + * idle task we require both the per-thread and per-process
> + * information to have more affinity with the remote CPU than with
> the
> + * current CPU for a migration to happen.=20

This doesn't explain anything in the dense code that follows.

What statistics, how are they used, with what goal etc..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
