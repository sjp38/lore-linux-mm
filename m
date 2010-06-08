Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7A55F6B01C3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:25:23 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:25:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
Message-Id: <20100608162513.c633439e.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006081141330.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
	<20100607084024.873B.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006081141330.18848@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010 11:43:13 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:
> 
> > I've put following historically remark in the description of the patch.
> > 
> > 
> >     We applied the exactly same patch in 2005:
> > 
> >         : commit ef08e3b4981aebf2ba9bd7025ef7210e8eec07ce
> >         : Author: Paul Jackson <pj@sgi.com>
> >         : Date:   Tue Sep 6 15:18:13 2005 -0700
> >         :
> >         : [PATCH] cpusets: confine oom_killer to mem_exclusive cpuset
> >         :
> >         : Now the real motivation for this cpuset mem_exclusive patch series seems
> >         : trivial.
> >         :
> >         : This patch keeps a task in or under one mem_exclusive cpuset from provoking an
> >         : oom kill of a task under a non-overlapping mem_exclusive cpuset.  Since only
> >         : interrupt and GFP_ATOMIC allocations are allowed to escape mem_exclusive
> >         : containment, there is little to gain from oom killing a task under a
> >         : non-overlapping mem_exclusive cpuset, as almost all kernel and user memory
> >         : allocation must come from disjoint memory nodes.
> >         :
> >         : This patch enables configuring a system so that a runaway job under one
> >         : mem_exclusive cpuset cannot cause the killing of a job in another such cpuset
> >         : that might be using very high compute and memory resources for a prolonged
> >         : time.
> > 
> >     And we changed it to current logic in 2006
> > 
> >         : commit 7887a3da753e1ba8244556cc9a2b38c815bfe256
> >         : Author: Nick Piggin <npiggin@suse.de>
> >         : Date:   Mon Sep 25 23:31:29 2006 -0700
> >         :
> >         : [PATCH] oom: cpuset hint
> >         :
> >         : cpuset_excl_nodes_overlap does not always indicate that killing a task will
> >         : not free any memory we for us.  For example, we may be asking for an
> >         : allocation from _anywhere_ in the machine, or the task in question may be
> >         : pinning memory that is outside its cpuset.  Fix this by just causing
> >         : cpuset_excl_nodes_overlap to reduce the badness rather than disallow it.
> > 
> >     And we haven't get the explanation why this patch doesn't reintroduced
> >     an old issue. 

hm, that was some good kernel archeological research.

> > I don't refuse a patch if it have multiple ack. But if you have any
> > material or number, please show us soon.
> > 
> 
> And this patch is acked by the 2006 patch's author, Nick Piggin.
> 
> There's obviously not going to be any "number" to show that this means 
> anything, but we've run it internally for three years to prevent needless 
> oom killing in other cpusets that don't have any indication that it will 
> free memory that current needs.

Well I wonder if Nick had observed some problem which the 2006 change
fixed.

And I wonder if David has observed some problem which the 2010 change
fixes!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
