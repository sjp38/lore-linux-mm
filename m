Subject: Re: [PATCH 2.6.17-rc1-mm1 2/6] Migrate-on-fault - check for
	misplaced page
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20060412094346.0a974f1c.pj@sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
	 <1144441382.5198.40.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
	 <20060412094346.0a974f1c.pj@sgi.com>
Content-Type: text/plain
Date: Wed, 12 Apr 2006 14:49:45 -0400
Message-Id: <1144867785.5229.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2006-04-12 at 09:43 -0700, Paul Jackson wrote:
> Christoph, respnonding to Lee:
> > > +			/*
> > > +			 * allows binding to multiple nodes.
> > > +			 * use current page if in zonelist,
> > > +			 * else select first allowed node
> > > +			 */
> > > +			mems = &pol->cpuset_mems_allowed;
> > > +			...
> > 
> > Hmm.... Checking for the current node in memory policy? How does this 
> > interact with cpuset constraints?
> 
> The per-mempolicy 'cpuset_mems_allowed' does not specify the nodes to
> which the task is bound, but rather the nodes to which the mempolicy is
> relative.  No code except the mempolicy rebinding code should be using
> the mempolicy->cpuset_mems_allowed field.
> 
> The proper way to check if a zone is allowed by cpusets appears
> in several places in the files mm/page_alloc.c, mm/vmscan.c, and
> mm/hugetlb.c.

Thanks, Paul.  But, I wonder, do I even need to do this check at all?
I just found the node in the policy's nodelist after having done a
cpuset_update_task_memory_state().  Looks like updating the task
memory state refreshes the policy zonelist, so it should only have nodes
valid in the cpuset.  Is this correct?

If so, I can just drop that check...

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
