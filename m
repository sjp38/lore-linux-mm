Date: Fri, 15 Feb 2008 03:55:48 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080215095548.GC1029@sgi.com>
References: <adazlu5vlub.fsf@cisco.com> <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com> <47B45994.7010805@opengridcomputing.com> <20080214155333.GA1029@sgi.com> <47B46AFB.9070009@opengridcomputing.com> <469958e00802140948j162cc8baqae0b55cd6fb1cd22@mail.gmail.com> <47B4A8CA.30306@anu.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47B4A8CA.30306@anu.edu.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Singleton <David.Singleton@anu.edu.au>
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>, Steve Wise <swise@opengridcomputing.com>, Robin Holt <holt@sgi.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, a.p.zijlstra@chello.nl, Roland Dreier <rdreier@cisco.com>, linux-mm@kvack.org, daniel.blueman@quadrics.com, general@lists.openfabrics.org, Christoph Lameter <clameter@sgi.com>, pw@osc.edu
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2008 at 07:47:06AM +1100, David Singleton wrote:
> Caitlin Bestler wrote:
>> But the broader question is what the goal is here. Allowing memory to
>> be shuffled is valuable, and perhaps even ultimately a requirement for
>> high availability systems. RDMA and other direct-access APIs should
>> be evolving their interfaces to accommodate these needs.
>> Oversubscribing memory is a totally different matter. If an application
>> is working with memory that is oversubscribed by a factor of 2 or more
>> can it really benefit from zero-copy direct placement? At first glance I
>> can't see what RDMA could be bringing of value when the overhead of
>> swapping is going to be that large.
>
> A related use case from HPC.  Some of us have batch scheduling
> systems based on suspend/resume of jobs (which is really just
> SIGSTOP and SIGCONT of all job processes).  The value of this
> system is enhanced greatly by being able to page out the suspended
> job (just normal Linux demand paging caused by the incoming job is
> OK).  Apart from this (relatively) brief period of paging, both
> jobs benefit from RDMA.
>
> SGI kindly implemented a /proc mechanism for unpinning of XPMEM
> pages to allow suspended jobs to be paged on their Altix system.
>
> Note that this use case would not benefit from Pete Wyckoff's
> approach of notifying user applications/libraries of VM changes.

We will be implementing xpmem on top of mmu_notifiers (actively working
on that now) so in that case, you would no longer need to use the
/proc/xpmem/<pid> mechanism for unpinning.  Hopefully, we will have xpmem
in before 2.6.26 and get it into the base OS now instead of an add-on.
Oh yeah, and memory migration will not need the unpin thing either so
you can move smaller jobs around more easily.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
