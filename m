Date: Fri, 15 Jul 2005 23:12:10 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-ID: <20050715211210.GI15783@wotan.suse.de>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com> <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com> <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com> <20050715140437.7399921f.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050715140437.7399921f.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

> These questions of interface style (filesys or syscall) probably don't
> matter, however. at least not yet.  First we need to make sense of
> the larger issues that Ken and Andi raise, of whether this is a good
> thing to do.

In my opinion detailed reporting of node affinity to external
processes of specific memory areas is a mistake. It's too finegrained and 
not useful outside the process itself (external users don't or shouldn't
know anything about process virtual addresses). The information
is too volatile and can change every time without nice 
ways to lock (no SIGSTOP is not a acceptable way) 

Some people might find it useful for debugging NUMA kernel code,
but that doesn't mean it has to go into the kernel.

For statistics purposes probably just some counters are enough.
Either generated on demand or counted. On demand would be 
probably slow and counted would bloat mm_struct because
it would need some max_numnodes sized arrays.   Not sure what
is the better tradeoff.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
