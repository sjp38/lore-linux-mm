Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 76AA46B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 05:37:28 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1066752pab.29
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 02:37:28 -0700 (PDT)
Received: by mail-ea0-f178.google.com with SMTP id a15so390203eae.23
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 02:37:24 -0700 (PDT)
Date: Thu, 26 Sep 2013 11:37:20 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20130926093720.GB24596@gmail.com>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
 <1380147049.3467.67.camel@schen9-DESK>
 <20130926064629.GB19090@gmail.com>
 <20130926084010.GQ3081@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926084010.GQ3081@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 26, 2013 at 08:46:29AM +0200, Ingo Molnar wrote:
> > > +/*
> > > + * MCS lock defines
> > > + *
> > > + * This file contains the main data structure and API definitions of MCS lock.
> > 
> > A (very) short blurb about what an MCS lock is would be nice here.
> 
> A while back I suggested including a link to something like:
> 
> http://www.cise.ufl.edu/tr/DOC/REP-1992-71.pdf
> 
> Its a fairly concise write-up of the idea; only 6 pages. The sad part 
> about linking to the web is that links tend to go dead after a while.

So what I wanted to see was to add just a few sentences summing up the 
concept - so that people blundering into this file in include/linux/ have 
an idea what it's all about!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
