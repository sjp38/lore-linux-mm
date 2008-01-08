Date: Tue, 8 Jan 2008 08:37:36 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
Message-ID: <20080108073736.GD22800@v2.random>
References: <504e981185254a12282d.1199326157@v2.random> <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0801071751320.13505@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.9999.0801071751320.13505@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 05:57:41PM -0800, David Rientjes wrote:
> That's only possible with my proposal of adding
> 
> 	unsigned long oom_kill_jiffies;
> 
> to struct task_struct.  We can't get away with a system-wide jiffies 

I already added it.

> variable, nor can we get away with per-cgroup, per-cpuset, or 
> per-mempolicy variable.  The only way to clear such a variable is in the 
> exit path (by checking test_thread_flag(tsk, TIF_MEMDIE) in do_exit()) and 
> fails miserably if there are simultaneous but zone-disjoint OOMs 
> occurring.

I don't see much issues with zone-disjoints oom with my current
patchset. The trouble is a new deadlock that I'm reproducing now, I
submit you privately a preview of the memdie_jiffies, did you see any
problem in my implementation? I guess I'll resubmit to linux-mm
too. The new deadlock I run into after adding memdie_jiffies is likely
unrelated to the memdie_jiffies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
