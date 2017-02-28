Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDB66B03B5
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:00:41 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so15448837pfb.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 06:00:41 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d185si1840454pgc.362.2017.02.28.06.00.39
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 06:00:40 -0800 (PST)
Date: Tue, 28 Feb 2017 23:00:23 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228140023.GA11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228130513.GH5680@worktop>
 <20170228132820.GH3817@X58A-UD3R>
 <20170228133521.GJ5680@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228133521.GJ5680@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Feb 28, 2017 at 02:35:21PM +0100, Peter Zijlstra wrote:
> On Tue, Feb 28, 2017 at 10:28:20PM +0900, Byungchul Park wrote:
> > On Tue, Feb 28, 2017 at 02:05:13PM +0100, Peter Zijlstra wrote:
> > > On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > > > +#define MAX_XHLOCKS_NR 64UL
> > > 
> > > > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > > > +	if (tsk->xhlocks) {
> > > > +		void *tmp = tsk->xhlocks;
> > > > +		/* Disable crossrelease for current */
> > > > +		tsk->xhlocks = NULL;
> > > > +		vfree(tmp);
> > > > +	}
> > > > +#endif
> > > 
> > > > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > > > +	p->xhlock_idx = 0;
> > > > +	p->xhlock_idx_soft = 0;
> > > > +	p->xhlock_idx_hard = 0;
> > > > +	p->xhlock_idx_nmi = 0;
> > > > +	p->xhlocks = vzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR);
> > > 
> > > I don't think we need vmalloc for this now.
> > 
> > Really? When is a better time to do it?
> > 
> > I think the time creating a task is the best time to initialize it. No?
> 
> The place is fine, but I would use kmalloc() now (and subsequently kfree
> on the other end) for the allocation. Its not _that_ large anymore,
> right?

Did you mean that? OK, I will do it.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
