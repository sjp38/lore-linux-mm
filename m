Date: Tue, 22 Oct 2002 09:14:41 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <2666588581.1035278080@[10.10.2.3]>
In-Reply-To: <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva>
References: <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Actually, per-object reverse mappings are nowhere near as good
> a solution as shared page tables.  At least, not from the points
> of view of space consumption and the overhead of tearing down
> the mappings at pageout time.
> 
> Per-object reverse mappings are better for fork+exec+exit speed,
> though.
> 
> It's a tradeoff: do we care more for a linear speedup of fork(),
> exec() and exit() than we care about a possibly exponential
> slowdown of the pageout code ?

As long as the box doesn't fall flat on it's face in a jibbering
heap, that's the first order of priority ... ie I don't care much
for now ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
