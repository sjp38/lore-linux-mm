Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 490A16B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:39:48 -0400 (EDT)
Message-ID: <1332164371.18960.339.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Mar 2012 14:39:31 +0100
In-Reply-To: <20120319130401.GI24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
	 <20120319130401.GI24602@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 14:04 +0100, Andrea Arcangeli wrote:
> In implementation terms the scheduler is simplified and it won't work
> as well as it should with massive CPU overcommit. But I had to take
> shortcuts to keep the complexity down to O(N) where N is the number of
> CPUS=20

Yeah I saw that, you essentially put a nr_cpus loop inside schedule(),
obviously that's not going to ever happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
