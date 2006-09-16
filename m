Date: Sat, 16 Sep 2006 08:18:46 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060916081846.e77c0f89.akpm@osdl.org>
In-Reply-To: <20060916043036.72d47c90.pj@sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915012810.81d9b0e3.akpm@osdl.org>
	<20060915203816.fd260a0b.pj@sgi.com>
	<20060915214822.1c15c2cb.akpm@osdl.org>
	<20060916043036.72d47c90.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2006 04:30:36 -0700
Paul Jackson <pj@sgi.com> wrote:

> Andrew wrote:
> > Why is it not sufficient to cache the most-recent zone*  in task_struct?
> 
> Because ...
> 
> pj - quoting himself:
> > Just one current_allocation_zone would not be enough.  Each node that
> > the cpuset allowed would require its own current_allocation_zone.  For
> > example, on a big honkin NUMA box with 2 CPUs per Node, tasks running
> > on CPU 32, Node 16, might be able to find free memory right on that
> > Node 16.  But another task in the same cpuset running on CPU 112, Node
> > 56 might have to scan past a dozen Nodes to Node 68 to find memory.
> 
> Extending the above example, the task on CPU 32 and the one on CPU
> 112 could be the same task, running in the same cpuset the whole time,
> after being rescheduled from one CPU to another.  The task would need
> not one cached most-recent zone*, but one for each node it might find
> itself on.
> 
> I'm pretty sure you don't want to put MAX_NUMNODES 'struct zone'
> pointers in each task struct.
> 

Could cache a zone* and the cpu number.  If the cpu number has changed
since last time, do another lookup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
