Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 14E516B006C
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:28:53 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c13so2235060eek.31
        for <linux-mm@kvack.org>; Fri, 19 Jul 2013 01:28:51 -0700 (PDT)
Date: Fri, 19 Jul 2013 10:28:48 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
Message-ID: <20130719082848.GA25784@gmail.com>
References: <20130716234438.C792C316@viggo.jf.intel.com>
 <20130717072100.GA14359@gmail.com>
 <20130718135157.2262e28b2c6e0f43a4d0fe7a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130718135157.2262e28b2c6e0f43a4d0fe7a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 17 Jul 2013 09:21:00 +0200 Ingo Molnar <mingo@kernel.org> wrote:
> 
> > 
> > * Dave Hansen <dave@sr71.net> wrote:
> > 
> > > I was investigating some TLB flush scaling issues and realized
> > > that we do not have any good methods for figuring out how many
> > > TLB flushes we are doing.
> > > 
> > > It would be nice to be able to do these in generic code, but the
> > > arch-independent calls don't explicitly specify whether we
> > > actually need to do remote flushes or not.  In the end, we really
> > > need to know if we actually _did_ global vs. local invalidations,
> > > so that leaves us with few options other than to muck with the
> > > counters from arch-specific code.
> 
> Spose so, if you really think it's worth it.  It's all downside for 
> uniprocessor machines. [...]

UP is slowly going extinct, but in any case these counters ought to inform 
us about TLB flushes even on UP systems:

> > > +		NR_TLB_LOCAL_FLUSH_ALL,
> > > +		NR_TLB_LOCAL_FLUSH_ONE,
> > > +		NR_TLB_LOCAL_FLUSH_ONE_KERNEL,

While these ought to be compiled out on UP kernels:

> > > +		NR_TLB_REMOTE_FLUSH,	/* cpu tried to flush others' tlbs */
> > > +		NR_TLB_REMOTE_FLUSH_RECEIVED,/* cpu received ipi for flush */

Right?

> > Please fix the vertical alignment of comments.
> 
> I looked - this isn't practical.
> 
> It would be nice to actually document these things though.  We don't 
> *have* to squeeze the comment into the RHS.

Agreed.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
