Date: Sat, 16 Jul 2005 23:00:12 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050716215121.6c04ffb0.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0507162256180.28788@schroedinger.engr.sgi.com>
References: <20050715214700.GJ15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
 <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
 <20050715234402.GN15783@wotan.suse.de> <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
 <20050716020141.GO15783@wotan.suse.de> <20050716163030.0147b6ba.pj@sgi.com>
 <Pine.LNX.4.62.0507162016470.27506@schroedinger.engr.sgi.com>
 <20050716215121.6c04ffb0.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: ak@suse.de, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Paul Jackson wrote:

> Christoph wrote:
> > Here is one approach to locking using xchg.
> 
> What I see here doesn't change the behaviour of the
> kernel any - just adds some locked exchanges, right?

Correct.
 
> I thought the hard part was having some other task
> change the current tasks mempolicy.  For example,
> how does one task sync another tasks mempolicy up
> with its cpuset, or synchronously get the policies
> zonelist or preferred node set correctly?

Could you give me some more detail on how this should integrate with 
cpusets? I am not aware of any thing that I would call "hard".

What do you mean by synchronously? The proc changes do best effort 
modifications. There is no transactional behavior that allows the changes 
of multiple items at once, nor is there any guarantee that the vma you are 
changing is still there after you have read /proc/<pid>/numa_maps. Why 
would such synchronicity be necessary?

> I guess that this approach is intended to show how
> to make it easy to add that hard part, right?

This is intended to provide race free update of the memory policy.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
