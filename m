Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA7106B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 21:32:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so79923516pfc.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 18:32:09 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 92si3583741pli.551.2017.08.09.18.32.08
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 18:32:08 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:30:54 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 05/14] lockdep: Implement crossrelease feature
Message-ID: <20170810013054.GW20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-6-git-send-email-byungchul.park@lge.com>
 <20170809140535.aerk2ivnf4kv2mgf@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809140535.aerk2ivnf4kv2mgf@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 09, 2017 at 04:05:35PM +0200, Peter Zijlstra wrote:
> On Mon, Aug 07, 2017 at 04:12:52PM +0900, Byungchul Park wrote:
> > diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
> > index fffe49f..0c8a1b8 100644
> > --- a/include/linux/lockdep.h
> > +++ b/include/linux/lockdep.h
> > @@ -467,6 +520,49 @@ static inline void lockdep_on(void)
> >  
> >  #endif /* !LOCKDEP */
> >  
> > +enum context_t {
> > +	HARD,
> > +	SOFT,
> > +	PROC,
> > +	CONTEXT_NR,
> > +};
> 
> Since this is the global namespace and those being somewhat generic
> names, I've renamed the lot:
> 
> +enum xhlock_context_t {
> +       XHLOCK_HARD,
> +       XHLOCK_SOFT,
> +       XHLOCK_PROC,
> +       XHLOCK_NR,
> +};

I like it. Thank you.

With a little feedback, it rather makes us a bit confused between
XHLOCK_NR and MAX_XHLOCK_NR. what about the following?

+enum xhlock_context_t {
+       XHLOCK_HARD,
+       XHLOCK_SOFT,
+       XHLOCK_PROC,
+       XHLOCK_CXT_NR,
+};

But it's trivial. I like yours, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
