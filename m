Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 5B9956B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:38:17 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2013 05:38:16 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 859F538C803B
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:38:11 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6V9cCUi190130
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:38:12 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6V9cAGg007073
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:38:12 -0400
Date: Wed, 31 Jul 2013 15:08:02 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 08/18] sched: Reschedule task on preferred NUMA node once
 selected
Message-ID: <20130731093802.GB4880@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-9-git-send-email-mgorman@suse.de>
 <CAJd=RBB8rzy8bZ1JWkkmGBX2ucZ0kr9aOsiiwgV2s0y9_0z6fw@mail.gmail.com>
 <20130731090727.GI2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130731090727.GI2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hillf Danton <dhillf@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-07-31 10:07:27]:

> On Wed, Jul 17, 2013 at 09:31:05AM +0800, Hillf Danton wrote:
> > On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
> > > +static int
> > > +find_idlest_cpu_node(int this_cpu, int nid)
> > > +{
> > > +       unsigned long load, min_load = ULONG_MAX;
> > > +       int i, idlest_cpu = this_cpu;
> > > +
> > > +       BUG_ON(cpu_to_node(this_cpu) == nid);
> > > +
> > > +       rcu_read_lock();
> > > +       for_each_cpu(i, cpumask_of_node(nid)) {
> > 
> > Check allowed CPUs first if task is given?
> > 
> 
> If the task is not allowed to run on the CPUs for that node then how
> were the NUMA hinting faults recorded?
> 

But still we could check if the task is allowed to run on a cpu before we
capture the load of the cpu. This would avoid us trying to select a cpu
whose load is low but which cannot run this task.

> -- 
> Mel Gorman
> SUSE Labs
> 

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
