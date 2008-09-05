Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85IWwQV013133
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 14:32:58 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85IVgGA140436
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 14:31:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85IVfce002518
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 14:31:42 -0400
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <87ej3yv588.fsf@basil.nowhere.org>
References: <20080905172132.GA11692@us.ibm.com>
	 <87ej3yv588.fsf@basil.nowhere.org>
Content-Type: text/plain
Date: Fri, 05 Sep 2008 11:31:54 -0700
Message-Id: <1220639514.25932.28.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-09-05 at 20:04 +0200, Andi Kleen wrote:
> Gary Hade <garyhade@us.ibm.com> writes:
> >
> > Add memory hotremove config option to x86_64
> >
> > Memory hotremove functionality can currently be configured into
> > the ia64, powerpc, and s390 kernels.  This patch makes it possible
> > to configure the memory hotremove functionality into the x86_64
> > kernel as well. 
> 
> You forgot to describe how you tested it? Does it actually work.
> And why do you want to do it it? What's the use case?

I will let Gary answer these :)

> The general understanding was that it doesn't work very well on a real
> machine at least because it cannot be controlled how that memory maps
> to real pluggable hardware (and you cannot completely empty a node at runtime)
> and a Hypervisor would likely use different interfaces anyways.

At this time we are interested on node remove (on x86_64). 
It doesn't really work well at this time - due to some of the structures
(pgdat etc) are striped across all nodes. These is no easy way to
relocate them. Yasunori Goto is working on patches to address some of
these issues.

But we are considering adding support to restrict/skip bootmem
allocations on selected nodes. That way, we should be able to do
node remove.

(BTW, on ppc64 this works fine - since we are interested mostly in
removing *some* sections of memory to give it back to hypervisor - 
not entire node removal).

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
