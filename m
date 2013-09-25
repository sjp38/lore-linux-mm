Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 543836B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 01:56:25 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5557331pbb.41
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 22:56:25 -0700 (PDT)
Date: Wed, 25 Sep 2013 07:55:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 5/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
Message-ID: <20130925055556.GA3081@twins.programming.kicks-ass.net>
References: <cover.1380057198.git.tim.c.chen@linux.intel.com>
 <1380061366.3467.54.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380061366.3467.54.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, Sep 24, 2013 at 03:22:46PM -0700, Tim Chen wrote:
> We will need the MCS lock code for doing optimistic spinning for rwsem.
> Extracting the MCS code from mutex.c and put into its own file allow us
> to reuse this code easily for rwsem.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  kernel/mutex.c |   58 ++++++-------------------------------------------------
>  1 files changed, 7 insertions(+), 51 deletions(-)

Wasn't this patch supposed to add include/linux/mcslock.h ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
