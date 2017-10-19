Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4496B0260
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:34:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n4so4213389wrb.8
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:34:44 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x71si1320525wma.228.2017.10.19.08.34.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 08:34:42 -0700 (PDT)
Date: Thu, 19 Oct 2017 17:34:34 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
In-Reply-To: <1508425527.2429.11.camel@wdc.com>
Message-ID: <alpine.DEB.2.20.1710191718260.1971@nanos>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>  <1508392531-11284-3-git-send-email-byungchul.park@lge.com> <1508425527.2429.11.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>

On Thu, 19 Oct 2017, Bart Van Assche wrote:

> On Thu, 2017-10-19 at 14:55 +0900, Byungchul Park wrote:
> > Now the performance regression was fixed, re-enable
> > CONFIG_LOCKDEP_CROSSRELEASE and CONFIG_LOCKDEP_COMPLETIONS.
> > 
> > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> > ---
> >  lib/Kconfig.debug | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> > index 90ea784..fe8fceb 100644
> > --- a/lib/Kconfig.debug
> > +++ b/lib/Kconfig.debug
> > @@ -1138,8 +1138,8 @@ config PROVE_LOCKING
> >  	select DEBUG_MUTEXES
> >  	select DEBUG_RT_MUTEXES if RT_MUTEXES
> >  	select DEBUG_LOCK_ALLOC
> > -	select LOCKDEP_CROSSRELEASE if BROKEN
> > -	select LOCKDEP_COMPLETIONS if BROKEN
> > +	select LOCKDEP_CROSSRELEASE
> > +	select LOCKDEP_COMPLETIONS
> >  	select TRACE_IRQFLAGS
> >  	default n
> >  	help
> 
> I do not agree with this patch. Although the traditional lock validation
> code can be proven not to produce false positives, that is not the case for
> the cross-release checks. These checks are prone to produce false positives.
> Many kernel developers, including myself, are not interested in spending
> time on analyzing false positive deadlock reports. So I think that it is
> wrong to enable cross-release checking unconditionally if PROVE_LOCKING has
> been enabled. What I think that should happen is that either the cross-
> release checking code is removed from the kernel or that
> LOCKDEP_CROSSRELEASE becomes a new kernel configuration option. That will
> give kernel developers who choose to enable PROVE_LOCKING the freedom to
> decide whether or not to enable LOCKDEP_CROSSRELEASE.

I really disagree with your reasoning completely

1) When lockdep was introduced more than ten years ago it was far from
   perfect and we spent a reasonable amount of time to improve it, analyze
   false positives and add the missing annotations all over the tree. That
   was a process which took years.

2) Surely nobody is interested in wasting time on analyzing false
   positives, but your (and other peoples) attidute of 'none of my
   business' is what makes kernel development extremly frustrating.

   It should be in the interest of everybody involved in kernel development
   to help with improving such features and not to lean back and wait for
   others to bring it into a shape which allows you to use it as you see
   fit.

That's not how community works and lockdep would not be in the shape it is
today, if only a handful of people would have used and improved it. Such
things only work when used widely and when we get enough information so we
can address the weak spots.

Thanks,

	tglx


   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
