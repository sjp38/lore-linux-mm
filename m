Date: Tue, 22 Oct 2002 13:19:30 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <20021022131930.A20957@redhat.com>
References: <2629464880.1035240956@[10.10.2.3]> <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Tue, Oct 22, 2002 at 02:09:47PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 22, 2002 at 02:09:47PM -0200, Rik van Riel wrote:
> On Mon, 21 Oct 2002, Martin J. Bligh wrote:
> 
> > I think it will for most of the situations we run aground with now
> > (normally 5000 oracle tasks sharing a 2Gb shared segment, or some
> > such monster).
> 
> 10 GB pagetable overhead, for 2 GB of data.  No customer I
> know would accept that much OS overhead.
> 
> To reduce the overhead we could either reclaim the page
> tables and reconstruct them when needed (lots of work) or
> we could share the page tables (less runtime overhead).

Or you use 4MB pages.  That tends to work much better and has less 
complexity.  Shared page tables don't work well on x86 when you have 
a database trying to access an SGA larger than the virtual address 
space, as each process tends to map its own window into the buffer 
pool.  Highmem with 32 bit va just plain sucks.  The right answer is 
to change the architecture of the application to not run with 5000 
unique processes.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
