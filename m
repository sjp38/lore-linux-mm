Date: Thu, 2 Aug 2007 11:56:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <20070802140904.GA16940@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708021152370.7719@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
 <20070802140904.GA16940@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Mel Gorman wrote:

> Hence the regression test is dependant on timing. The question is if the values
> should always be up-to-date when read from userspace. I put together one patch
> that would refresh the counters when numastat or vmstat was being read but it
> requires a per-cpu function to be called. This may be undesirable as it would
> be punishing on large systems running tools that frequently read /proc/vmstat
> for example. Was it done this way on purpose? The comments around the stats
> code would led me to believe this lag is on purpose to avoid per-cpu calls.

The lag was introduced with the vm statistics rework since ZVCs use 
deferred updates. We could call refresh_vm_stats before handing out the 
counters?

> The alternative was to apply this patch to numactl so that the
> regression test waits on the timers to update. With this patch, the
> regression tests passed on a 4-node x86_64 machine.

Another possible solution. Andi: Which solution would you prefer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
