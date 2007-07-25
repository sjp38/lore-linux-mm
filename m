Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6PEkXpj022817
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 10:46:33 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6PFokro557354
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 11:50:46 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6PFokEV027390
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 11:50:46 -0400
Date: Wed, 25 Jul 2007 08:50:44 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH take2] Memoryless nodes:  use "node_memory_map" for cpuset mems_allowed validation
Message-ID: <20070725155044.GD18510@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182250.005856256@sgi.com> <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com> <1185286525.5649.27.camel@localhost> <20070724161925.GB18510@us.ibm.com> <1185303693.5649.45.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1185303693.5649.45.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 24.07.2007 [15:01:33 -0400], Lee Schermerhorn wrote:
> On Tue, 2007-07-24 at 09:19 -0700, Nishanth Aravamudan wrote:
> > On 24.07.2007 [10:15:25 -0400], Lee Schermerhorn wrote:
> > > Memoryless Nodes:  use "node_memory_map" for cpusets - take 2
> > > 
> > > Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless nodes
> > > series
> > > 
> > > take 2:
> > > + replaced node_online_map in cpuset_current_mems_allowed()
> > >   with node_states[N_MEMORY]
> > > + replaced node_online_map in cpuset_init_smp() with
> > >   node_states[N_MEMORY]
> > > 
> > > cpusets try to ensure that any node added to a cpuset's 
> > > mems_allowed is on-line and contains memory.  The assumption
> > > was that online nodes contained memory.  Thus, it is possible
> > > to add memoryless nodes to a cpuset and then add tasks to this
> > > cpuset.  This results in continuous series of oom-kill and
> > > apparent system hang.
> > > 
> > > Change cpusets to use node_states[N_MEMORY] [a.k.a.
> > > node_memory_map] in place of node_online_map when vetting 
> > > memories.  Return error if admin attempts to write a non-empty
> > > mems_allowed node mask containing only memoryless-nodes.
> > 
> > I think you still are missing a few comment changes (anything mentioning
> > 'track'ing node_online_map will need to be changed, I think). Also, I
> > don't see the necessary change in common_cpu_mem_hotplug_unplug()
> > similar to cpuset_init_smp()'s change.
> 
> Sorry.  Multitasking meltdown...  Will fix.
> 
> Meanwhile:  
> 
> I've tested your 3 patches atop Christoph's series [on 22-rc6-mm1],
> with and without my cpuset patch and I can't reproduce the hang I saw
> a couple of days ago :-(.  I hate it when that happens!  Perhaps some
> system daemon started up during the test that hung.

Hrm, that stinks. I tested on several h/w variations before posting. And
the changes are pretty transparent, so I'm not sure where we'd hang (and
I would think if we were, we'd see it now too). But I'll do another
audit just to be sure.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
