Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 412266B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:12:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u138so3969156wmu.19
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:12:09 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f55si12670404wrf.288.2017.10.19.12.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 12:12:08 -0700 (PDT)
Date: Thu, 19 Oct 2017 21:12:00 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
In-Reply-To: <alpine.DEB.2.20.1710192021480.2054@nanos>
Message-ID: <alpine.DEB.2.20.1710192107000.2054@nanos>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>  <1508392531-11284-3-git-send-email-byungchul.park@lge.com>  <1508425527.2429.11.camel@wdc.com>  <alpine.DEB.2.20.1710191718260.1971@nanos> <1508428021.2429.22.camel@wdc.com>
 <alpine.DEB.2.20.1710192021480.2054@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "kernel-team@lge.com" <kernel-team@lge.com>

On Thu, 19 Oct 2017, Thomas Gleixner wrote:
> That's not a lockdep problem and neither can the pure locking dependency
> tracking know that a particular deadlock is not possible by design. It can
> merily record the dependency chains and detect circular dependencies.
> 
> There is enough code which is obviously correct in terms of locking which
> has lockdep annotations in one form or the other (nesting, different
> lock_class_keys etc.). These annotations are there to teach lockdep about
> false positives. It's pretty much the same with the cross release feature
> and we won't get these annotations into the code when people disable it 

And just for the record, I wasted enough of my time already to decode 'can
not happen' dead locks where completions or other wait primitives have been
involved. I rather spend time annotating stuff after analyzing it proper
than chasing happens once in a blue moon lockups which are completely
unexplainable.

That's why lockdep exists in the first place. Ingo, Steven, myself and
others spent an insane amount of time to fix locking bugs all over the tree
when we started the preempt RT work. Lockdep was a rescue because it forced
people to look at their own crap and if it was 100% clear that lockdep
tripped a false positive either lockdep was fixed or the code in question
annotated, which is a good thing because that's documentation at the same
time.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
