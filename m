Date: Tue, 22 Oct 2002 14:06:55 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
In-Reply-To: <2666588581.1035278080@[10.10.2.3]>
Message-ID: <Pine.LNX.3.96.1021022135649.7820C-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Oct 2002, Martin J. Bligh wrote:

> > Actually, per-object reverse mappings are nowhere near as good
> > a solution as shared page tables.  At least, not from the points
> > of view of space consumption and the overhead of tearing down
> > the mappings at pageout time.
> > 
> > Per-object reverse mappings are better for fork+exec+exit speed,
> > though.
> > 
> > It's a tradeoff: do we care more for a linear speedup of fork(),
> > exec() and exit() than we care about a possibly exponential
> > slowdown of the pageout code ?

That tradeoff makes the case for spt being a kbuild or /proc/sys option. A
linear speedup of fork/exec/exit is likely to be more generally useful,
most people just don't have huge shared areas. On the other hand, those
who do would get a vast improvement, and that would put Linux a major step
forward in the server competition.
 
> As long as the box doesn't fall flat on it's face in a jibbering
> heap, that's the first order of priority ... ie I don't care much
> for now ;-)

I'm just trying to decide what this might do for a news server with
hundreds of readers mmap()ing a GB history file. Benchmarks show the 2.5
has more latency the 2.4, and this is likely to make that more obvious.

Is there any way to to have this only on processes which really need it?
define that any way you wish, including hanging a capability on the
executable to get spt.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
