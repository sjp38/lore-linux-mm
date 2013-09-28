Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6023B6B0031
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 03:54:39 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so3505681pbb.27
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 00:54:39 -0700 (PDT)
Date: Sat, 28 Sep 2013 09:54:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] checkpatch: Make the memory barrier test noisier
Message-ID: <20130928075409.GK15690@laptop.programming.kicks-ass.net>
References: <1380236265.3467.103.camel@schen9-DESK>
 <20130927060213.GA6673@gmail.com>
 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
 <1380289495.17366.91.camel@joe-AO722>
 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
 <1380291257.17366.103.camel@joe-AO722>
 <20130927142605.GC15690@laptop.programming.kicks-ass.net>
 <1380292495.17366.106.camel@joe-AO722>
 <20130927145007.GD15690@laptop.programming.kicks-ass.net>
 <1380325227.1631.2.camel@linux-fkkt.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380325227.1631.2.camel@linux-fkkt.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver Neukum <oliver@neukum.org>
Cc: Joe Perches <joe@perches.com>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Sat, Sep 28, 2013 at 01:40:27AM +0200, Oliver Neukum wrote:
> On Fri, 2013-09-27 at 16:50 +0200, Peter Zijlstra wrote:
> > On Fri, Sep 27, 2013 at 07:34:55AM -0700, Joe Perches wrote:
> > > That would make it seem as if all barriers are SMP no?
> > 
> > I would think any memory barrier is ordering against someone else; if
> > not smp then a device/hardware -- like for instance the hardware page
> > table walker.
> > 
> > Barriers are fundamentally about order; and order only makes sense if
> > there's more than 1 party to the game.
> 
> But not necessarily more than 1 kind of parties. It is perfectly
> possible to have a barrier against other threads running the same
> function.

Then that makes a good comment ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
