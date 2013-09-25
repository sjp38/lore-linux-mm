Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 71D9C6B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:59:36 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so6234368pbb.0
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 08:59:36 -0700 (PDT)
Subject: Re: [PATCH v5 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130925055556.GA3081@twins.programming.kicks-ass.net>
References: <cover.1380057198.git.tim.c.chen@linux.intel.com>
	 <1380061366.3467.54.camel@schen9-DESK>
	 <20130925055556.GA3081@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 25 Sep 2013 08:58:53 -0700
Message-ID: <1380124733.3467.61.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Wed, 2013-09-25 at 07:55 +0200, Peter Zijlstra wrote:
> On Tue, Sep 24, 2013 at 03:22:46PM -0700, Tim Chen wrote:
> > We will need the MCS lock code for doing optimistic spinning for rwsem.
> > Extracting the MCS code from mutex.c and put into its own file allow us
> > to reuse this code easily for rwsem.
> > 
> > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > ---
> >  kernel/mutex.c |   58 ++++++-------------------------------------------------
> >  1 files changed, 7 insertions(+), 51 deletions(-)
> 
> Wasn't this patch supposed to add include/linux/mcslock.h ?

Thanks for catching it.  I will correct it.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
