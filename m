Message-ID: <47B4A8CA.30306@anu.edu.au>
Date: Fri, 15 Feb 2008 07:47:06 +1100
From: David Singleton <David.Singleton@anu.edu.au>
Reply-To: David.Singleton@anu.edu.au
MIME-Version: 1.0
Subject: Re: [ofa-general] Re: Demand paging for memory regions
References: <adazlu5vlub.fsf@cisco.com>	 <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>	 <47B45994.7010805@opengridcomputing.com>	 <20080214155333.GA1029@sgi.com>	 <47B46AFB.9070009@opengridcomputing.com> <469958e00802140948j162cc8baqae0b55cd6fb1cd22@mail.gmail.com>
In-Reply-To: <469958e00802140948j162cc8baqae0b55cd6fb1cd22@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Caitlin Bestler <caitlin.bestler@gmail.com>
Cc: Steve Wise <swise@opengridcomputing.com>, Robin Holt <holt@sgi.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, a.p.zijlstra@chello.nl, Roland Dreier <rdreier@cisco.com>, linux-mm@kvack.org, daniel.blueman@quadrics.com, general@lists.openfabrics.org, Christoph Lameter <clameter@sgi.com>, pw@osc.edu
List-ID: <linux-mm.kvack.org>

Caitlin Bestler wrote:
> 
> But the broader question is what the goal is here. Allowing memory to
> be shuffled is valuable, and perhaps even ultimately a requirement for
> high availability systems. RDMA and other direct-access APIs should
> be evolving their interfaces to accommodate these needs.
> 
> Oversubscribing memory is a totally different matter. If an application
> is working with memory that is oversubscribed by a factor of 2 or more
> can it really benefit from zero-copy direct placement? At first glance I
> can't see what RDMA could be bringing of value when the overhead of
> swapping is going to be that large.
> 

A related use case from HPC.  Some of us have batch scheduling
systems based on suspend/resume of jobs (which is really just
SIGSTOP and SIGCONT of all job processes).  The value of this
system is enhanced greatly by being able to page out the suspended
job (just normal Linux demand paging caused by the incoming job is
OK).  Apart from this (relatively) brief period of paging, both
jobs benefit from RDMA.

SGI kindly implemented a /proc mechanism for unpinning of XPMEM
pages to allow suspended jobs to be paged on their Altix system.

Note that this use case would not benefit from Pete Wyckoff's
approach of notifying user applications/libraries of VM changes.

And one of the grand goal of HPC developers has always been to have
checkpoint/restart of jobs ....

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
