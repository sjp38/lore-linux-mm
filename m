Date: Tue, 22 Oct 2002 13:54:39 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
In-Reply-To: <Pine.LNX.4.44L.0210221221460.25116-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.3.96.1021022135013.7820B-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Oct 2002, Rik van Riel wrote:

> On 21 Oct 2002, Eric W. Biederman wrote:
> > "Martin J. Bligh" <mbligh@aracnet.com> writes:

> > We swap pages out all of the time in 2.4.x, and that is all I was
> > suggesting swap out some but not all of the pages, on a very long
> > pte_chain.  And swapping out a page is not terribly complex, unless
> > something very drastic has changed.
> 
> Imagine a slightly larger than normal Oracle server.
> Say 5000 processes with 1 GB of shared memory.
> 
> Just the page tables needed to map this memory would
> take up 5 GB of RAM ... with shared page tables we
> only need 1 MB of page tables.
> 
> The corresponding reduction in rmaps is a nice bonus,
> but hardly any more dramatic than the page table
> overhead.
> 
> In short, we really really want shared page tables.

Does using spt require mapping the pages at the same location in all
processes?

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
