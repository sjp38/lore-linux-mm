Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id AB0876B0081
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 10:50:34 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so2665140pdj.7
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 07:50:34 -0700 (PDT)
Date: Fri, 27 Sep 2013 16:50:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] checkpatch: Make the memory barrier test noisier
Message-ID: <20130927145007.GD15690@laptop.programming.kicks-ass.net>
References: <1380231702.3467.85.camel@schen9-DESK>
 <1380235333.3229.39.camel@j-VirtualBox>
 <1380236265.3467.103.camel@schen9-DESK>
 <20130927060213.GA6673@gmail.com>
 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
 <1380289495.17366.91.camel@joe-AO722>
 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
 <1380291257.17366.103.camel@joe-AO722>
 <20130927142605.GC15690@laptop.programming.kicks-ass.net>
 <1380292495.17366.106.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380292495.17366.106.camel@joe-AO722>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Sep 27, 2013 at 07:34:55AM -0700, Joe Perches wrote:
> That would make it seem as if all barriers are SMP no?

I would think any memory barrier is ordering against someone else; if
not smp then a device/hardware -- like for instance the hardware page
table walker.

Barriers are fundamentally about order; and order only makes sense if
there's more than 1 party to the game.

> Maybe just refer to Documentation/memory-barriers.txt
> and/or say something like "please document appropriately"

Documentation/memory-barriers.txt is always good; appropriately doesn't
seem to quantify anything much at all. Someone might think:

/*  */
smp_mb();

appropriate... 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
