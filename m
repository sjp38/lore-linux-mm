Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E44596B004D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 14:06:28 -0500 (EST)
Date: Mon, 1 Feb 2010 13:06:24 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP 1/3] srcu
Message-ID: <20100201190624.GJ6653@sgi.com>
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
 <20100128195633.998332000@alcatraz.americas.sgi.com>
 <20100129125650.78ca4876.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100129125650.78ca4876.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 12:56:50PM -0800, Andrew Morton wrote:
> 
> > Subject: [RFP 1/3] srcu
> 
> Well that was terse.
> 
> On Thu, 28 Jan 2010 13:56:28 -0600
> Robin Holt <holt@sgi.com> wrote:
> 
> > From: Andrea Arcangeli <andrea@qumranet.com>
> > 
> > This converts rcu into a per-mm srcu to allow all mmu notifier methods to
> > schedule.
> 
> Changelog doesn't make much sense.

I made the changelog a little more verbose and hopefully a little
more clear.

> 
> > --- mmu_notifiers_sleepable_v1.orig/include/linux/srcu.h	2010-01-28 10:36:39.000000000 -0600
> > +++ mmu_notifiers_sleepable_v1/include/linux/srcu.h	2010-01-28 10:39:10.000000000 -0600
> > @@ -27,6 +27,8 @@
> >  #ifndef _LINUX_SRCU_H
> >  #define _LINUX_SRCU_H
> >  
> > +#include <linux/mutex.h>
> > +
> >  struct srcu_struct_array {
> >  	int c[2];
> >  };
> 
> An unchangelogged, unrelated bugfix.  I guess it's OK slipping this
> into this patch.

Removed.  This does not appear to be needed as it mmu_notifier.c compiles
without warning.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
