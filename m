Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id EBAA46B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 12:02:01 -0400 (EDT)
Date: Tue, 16 Jul 2013 17:01:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 16/18] sched: Avoid overloading CPUs on a preferred NUMA
 node
Message-ID: <20130716160157.GK5055@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-17-git-send-email-mgorman@suse.de>
 <CAJd=RBAxApb2Hoz06_7Ry1Z-TSAWGp9QJCfLP5NPPm2kiUF+Bg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBAxApb2Hoz06_7Ry1Z-TSAWGp9QJCfLP5NPPm2kiUF+Bg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 16, 2013 at 11:55:24PM +0800, Hillf Danton wrote:
> On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
> > +
> > +static int task_numa_find_cpu(struct task_struct *p, int nid)
> > +{
> > +       int node_cpu = cpumask_first(cpumask_of_node(nid));
> [...]
> >
> > +       /* No harm being optimistic */
> > +       if (idle_cpu(node_cpu))
> > +               return node_cpu;
> >
> [...]
> > +       for_each_cpu(cpu, cpumask_of_node(nid)) {
> > +               dst_load = target_load(cpu, idx);
> > +
> > +               /* If the CPU is idle, use it */
> > +               if (!dst_load)
> > +                       return dst_cpu;
> > +
> Here you want cpu, instead of dst_cpu, I guess.

Crap, yes. Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
