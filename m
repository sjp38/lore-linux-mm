Date: Tue, 22 Oct 2002 12:26:55 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
In-Reply-To: <m17kgbuo0i.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.44L.0210221221460.25116-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 21 Oct 2002, Eric W. Biederman wrote:
> "Martin J. Bligh" <mbligh@aracnet.com> writes:
>
> > > So why has no one written a pte_chain reaper?  It is perfectly sane
> > > to allocate a swap entry and move an entire pte_chain to the swap
> > > cache.
> >
> > I think the underlying subsystem does not easily allow for dynamic regeneration,
> > so it's non-trivial.
>
> We swap pages out all of the time in 2.4.x, and that is all I was
> suggesting swap out some but not all of the pages, on a very long
> pte_chain.  And swapping out a page is not terribly complex, unless
> something very drastic has changed.

Imagine a slightly larger than normal Oracle server.
Say 5000 processes with 1 GB of shared memory.

Just the page tables needed to map this memory would
take up 5 GB of RAM ... with shared page tables we
only need 1 MB of page tables.

The corresponding reduction in rmaps is a nice bonus,
but hardly any more dramatic than the page table
overhead.

In short, we really really want shared page tables.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
