Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCA766B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:53:12 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y10so4065778wmd.4
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:53:12 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s199si1749615wmd.100.2017.10.19.13.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 13:53:11 -0700 (PDT)
Date: Thu, 19 Oct 2017 22:53:06 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
In-Reply-To: <1508445681.2429.61.camel@wdc.com>
Message-ID: <alpine.DEB.2.20.1710192250140.2054@nanos>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>  <1508392531-11284-3-git-send-email-byungchul.park@lge.com>  <1508425527.2429.11.camel@wdc.com>  <alpine.DEB.2.20.1710191718260.1971@nanos>  <1508428021.2429.22.camel@wdc.com>
 <alpine.DEB.2.20.1710192021480.2054@nanos>  <alpine.DEB.2.20.1710192107000.2054@nanos>  <1508444515.2429.55.camel@wdc.com>  <20171019203313.GA10538@bombadil.infradead.org> <1508445681.2429.61.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "willy@infradead.org" <willy@infradead.org>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>

On Thu, 19 Oct 2017, Bart Van Assche wrote:
> On Thu, 2017-10-19 at 13:33 -0700, Matthew Wilcox wrote:
> > For example, the page lock is not annotatable with lockdep -- we return
> > to userspace with it held, for heaven's sake!  So it is quite easy for
> > someone not familiar with the MM locking hierarchy to inadvertently
> > introduce an ABBA deadlock against the page lock.  (ie me.  I did that.)
> > Right now, that has to be caught by a human reviewer; if cross-release
> > checking can catch that, then it's worth having.
> 
> Hello Matthew,
> 
> Although I agree that enabling lock inversion checking for page locks is
> useful, I think my questions still apply to other locking objects than page
> locks.

Why are other objects any different?

    lock(L)   ->      wait_for_completion(A)
    lock(L)   ->      complete(A)

is a simple ABBA and they exist and have not been caught for a long time
until they choked a production machine.

Thanks,

	tglx




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
