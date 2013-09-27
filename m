Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id EC4C36B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 19:40:34 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so3224001pdj.22
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:40:34 -0700 (PDT)
Message-ID: <1380325227.1631.2.camel@linux-fkkt.site>
Subject: Re: [PATCH] checkpatch: Make the memory barrier test noisier
From: Oliver Neukum <oliver@neukum.org>
Date: Sat, 28 Sep 2013 01:40:27 +0200
In-Reply-To: <20130927145007.GD15690@laptop.programming.kicks-ass.net>
References: <1380231702.3467.85.camel@schen9-DESK>
	 <1380235333.3229.39.camel@j-VirtualBox>
	 <1380236265.3467.103.camel@schen9-DESK> <20130927060213.GA6673@gmail.com>
	 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
	 <1380289495.17366.91.camel@joe-AO722>
	 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
	 <1380291257.17366.103.camel@joe-AO722>
	 <20130927142605.GC15690@laptop.programming.kicks-ass.net>
	 <1380292495.17366.106.camel@joe-AO722>
	 <20130927145007.GD15690@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Joe Perches <joe@perches.com>, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-09-27 at 16:50 +0200, Peter Zijlstra wrote:
> On Fri, Sep 27, 2013 at 07:34:55AM -0700, Joe Perches wrote:
> > That would make it seem as if all barriers are SMP no?
> 
> I would think any memory barrier is ordering against someone else; if
> not smp then a device/hardware -- like for instance the hardware page
> table walker.
> 
> Barriers are fundamentally about order; and order only makes sense if
> there's more than 1 party to the game.

But not necessarily more than 1 kind of parties. It is perfectly
possible to have a barrier against other threads running the same
function.

	Regards
		Oliver


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
