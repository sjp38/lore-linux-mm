Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4748F6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:07:32 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:07:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/18] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130731090727.GI2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-9-git-send-email-mgorman@suse.de>
 <CAJd=RBB8rzy8bZ1JWkkmGBX2ucZ0kr9aOsiiwgV2s0y9_0z6fw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBB8rzy8bZ1JWkkmGBX2ucZ0kr9aOsiiwgV2s0y9_0z6fw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 17, 2013 at 09:31:05AM +0800, Hillf Danton wrote:
> On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
> > +static int
> > +find_idlest_cpu_node(int this_cpu, int nid)
> > +{
> > +       unsigned long load, min_load = ULONG_MAX;
> > +       int i, idlest_cpu = this_cpu;
> > +
> > +       BUG_ON(cpu_to_node(this_cpu) == nid);
> > +
> > +       rcu_read_lock();
> > +       for_each_cpu(i, cpumask_of_node(nid)) {
> 
> Check allowed CPUs first if task is given?
> 

If the task is not allowed to run on the CPUs for that node then how
were the NUMA hinting faults recorded?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
