Date: Mon, 8 Sep 2008 12:30:15 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080908103015.GE26079@one.firstfloor.org>
References: <20080905215452.GF11692@us.ibm.com> <200809081552.50126.nickpiggin@yahoo.com.au> <20080908093619.GC26079@one.firstfloor.org> <200809081946.31521.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200809081946.31521.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 08, 2008 at 07:46:30PM +1000, Nick Piggin wrote:
> On Monday 08 September 2008 19:36, Andi Kleen wrote:
> > > You use non-linear mappings for the kernel, so that kernel data is
> > > not tied to a specific physical address. AFAIK, that is the only way
> > > to really do it completely (like the fragmentation problem).
> >
> > Even with that there are lots of issues, like keeping track of
> > DMAs or handling executing kernel code.
> 
> Right, but the "high level" software solution is to have nonlinear
> kernel mappings. Executing kernel code should not be so hard because
> it could be handled just like executing user code (ie. the CPU that
> is executing will subsequently fault and be blocked until the
> relocation is complete).

First blocking arbitary code is hard. There is some code parts
which are not allowed to block arbitarily. Machine check or NMI
handlers come to mind, but there are likely more.

Then that would be essentially a hypervisor or micro kernel approach.
e.g. Xen does that already kind of, but even there it would
be quite hard to do fully in a general way. And for hardware hotplug
only the fully generally way is actually useful unfortunately.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
