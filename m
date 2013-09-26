Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 855616B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 14:18:49 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1507590pdj.32
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:18:49 -0700 (PDT)
Subject: Re: [PATCH v6 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130926084010.GQ3081@twins.programming.kicks-ass.net>
References: <cover.1380144003.git.tim.c.chen@linux.intel.com>
	 <1380147049.3467.67.camel@schen9-DESK> <20130926064629.GB19090@gmail.com>
	 <20130926084010.GQ3081@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 Sep 2013 11:18:42 -0700
Message-ID: <1380219522.3467.72.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, 2013-09-26 at 10:40 +0200, Peter Zijlstra wrote:
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

Link rot is a problem.  If I provide a few details about MCS lock I
think people should be able to google for it.

Tim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
