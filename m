Date: Fri, 25 Oct 2002 13:31:41 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
In-Reply-To: <2832683854.1035444175@[10.10.2.3]>
Message-ID: <Pine.LNX.3.96.1021025133002.19333A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Oct 2002, Martin J. Bligh wrote:

> > Another thought, how does this play with NUMA systems? I don't have the
> > problem, but presumably there are implications.
> 
> At some point we'll probably only want one shared set per node.
> Gets tricky when you migrate processes across nodes though - will
> need more thought

The whole issue of pages shared between nodes is a graduate thesis waiting
to happen.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
