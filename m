Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1805A6B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:40:46 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so843608pbc.9
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 01:40:45 -0700 (PDT)
Date: Thu, 26 Sep 2013 10:40:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20130926084010.GQ3081@twins.programming.kicks-ass.net>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
 <1380147049.3467.67.camel@schen9-DESK>
 <20130926064629.GB19090@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926064629.GB19090@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, Sep 26, 2013 at 08:46:29AM +0200, Ingo Molnar wrote:
> > +/*
> > + * MCS lock defines
> > + *
> > + * This file contains the main data structure and API definitions of MCS lock.
> 
> A (very) short blurb about what an MCS lock is would be nice here.

A while back I suggested including a link to something like:

http://www.cise.ufl.edu/tr/DOC/REP-1992-71.pdf

Its a fairly concise write-up of the idea; only 6 pages. The sad part
about linking to the web is that links tend to go dead after a while.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
