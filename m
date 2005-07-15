Date: Sat, 16 Jul 2005 00:56:35 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-ID: <20050715225635.GM15783@wotan.suse.de>
References: <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com> <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de> <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com> <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com> <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com> <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 15, 2005 at 03:49:33PM -0700, Christoph Lameter wrote:
> On Sat, 16 Jul 2005, Andi Kleen wrote:
> 
> > > 1. Updating the memory policy is something that can be useful in other 
> > >    settings as well so it need to be separate. The patch we are discussing
> > 
> > Not for external processes except in the narrow special case
> > of migrating everything. External processes shouldn' t
> > know about virtual addresses of other people.
> 
> Updating the memory policy is also useful if memory on one node gets 
> short and you want to redirct allocations to a node that has memory free. 

If you use MEMBIND just specify all the nodes upfront and it'll
do the normal fallback in them. 

If you use PREFERED it'll do that automatically anyways.

> 
> A batch scheduler may anticipate memory shortages and redirect memory 
> allocations in order to avoid page migration.

I think that jobs more belongs to the kernel. After all we don't
want to move half of our VM into your proprietary scheduler.


> I'd rather have that logic in userspace rather than fix up page_migrate 
> again and again and again. Automatic recalculation of memory policies is 
> likely an unexpected side effect of the existing page migration code. 

Only if you migrate again and again.

> 
> Policies should only change with explicit instructions from user space and 
> not as a side effect of page migration.

Well, page migration would be a "explicit instruction from user space" 

> 
> And curiously with the old page migration code: The only way to change the 
> a memory policy is by page migration and this is automatically behind your 
> back.

mbind can change policy at any time. Just only for the local
process, as that is the the only one who has enough information
to really do this.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
