Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD506B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:39:57 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id u188so122668632wmu.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:39:57 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id t9si3979154wjf.169.2016.01.26.12.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 12:39:56 -0800 (PST)
Date: Tue, 26 Jan 2016 21:38:52 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <20160126181903.GB4671@osiris>
Message-ID: <alpine.DEB.2.11.1601262138260.3886@nanos>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com> <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com> <20160126181903.GB4671@osiris>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On Tue, 26 Jan 2016, Heiko Carstens wrote:
> On Tue, Jan 26, 2016 at 10:18:25AM +0100, Christian Borntraeger wrote:
> > We can use debug_pagealloc_enabled() to check if we can map
> > the identity mapping with 1MB/2GB pages as well as to print
> > the current setting in dump_stack.
> > 
> > Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> > ---
> >  arch/s390/kernel/dumpstack.c |  4 +++-
> >  arch/s390/mm/vmem.c          | 10 ++++------
> >  2 files changed, 7 insertions(+), 7 deletions(-)
> > 
> > diff --git a/arch/s390/kernel/dumpstack.c b/arch/s390/kernel/dumpstack.c
> > index dc8e204..a1c0530 100644
> > --- a/arch/s390/kernel/dumpstack.c
> > +++ b/arch/s390/kernel/dumpstack.c
> > @@ -11,6 +11,7 @@
> >  #include <linux/export.h>
> >  #include <linux/kdebug.h>
> >  #include <linux/ptrace.h>
> > +#include <linux/mm.h>
> >  #include <linux/module.h>
> >  #include <linux/sched.h>
> >  #include <asm/processor.h>
> > @@ -186,7 +187,8 @@ void die(struct pt_regs *regs, const char *str)
> >  	printk("SMP ");
> >  #endif
> >  #ifdef CONFIG_DEBUG_PAGEALLOC
> > -	printk("DEBUG_PAGEALLOC");
> > +	printk("DEBUG_PAGEALLOC(%s)",
> > +		debug_pagealloc_enabled() ? "enabled" : "disabled");
> >  #endif
> 
> I'd prefer if you change this to
> 
> 	if (debug_pagealloc_enabled())
> 		printk("DEBUG_PAGEALLOC");
> 
> That way we can get rid of yet another ifdef. Having
> "DEBUG_PAGEALLOC(disabled)" doesn't seem to be very helpful.

Yes, same for x86 please.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
