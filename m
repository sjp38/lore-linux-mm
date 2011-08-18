Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 896796B0169
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 19:51:47 -0400 (EDT)
Date: Thu, 18 Aug 2011 18:51:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] mm: Distinguish between mlocked and pinned pages
In-Reply-To: <20110817155412.cc302033.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1108181851100.11512@router.home>
References: <alpine.DEB.2.00.1108101516430.20403@router.home> <20110817155412.cc302033.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-rdma@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Wed, 17 Aug 2011, Andrew Morton wrote:

> Sounds reasonable.  But how do we prevent future confusion?  We should
> carefully define these terms in an obvious place, please.

Ok.

> > --- linux-2.6.orig/include/linux/mm_types.h	2011-08-10 14:08:42.000000000 -0500
> > +++ linux-2.6/include/linux/mm_types.h	2011-08-10 14:09:02.000000000 -0500
> > @@ -281,7 +281,7 @@ struct mm_struct {
> >  	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
> >  	unsigned long hiwater_vm;	/* High-water virtual memory usage */
> >
> > -	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
> > +	unsigned long total_vm, locked_vm, pinned_vm, shared_vm, exec_vm;
> >  	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
> >  	unsigned long start_code, end_code, start_data, end_data;
> >  	unsigned long start_brk, brk, start_stack;
>
> This is an obvious place.  Could I ask that you split all these up into
> one-definition-per-line and we can start in on properly documenting
> each field?

Will do that after the linuxcon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
