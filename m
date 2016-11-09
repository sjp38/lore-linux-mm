Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8116B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:43:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so89877137wms.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:43:02 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id jf4si1631535wjb.265.2016.11.09.13.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 13:43:01 -0800 (PST)
Date: Wed, 9 Nov 2016 22:40:24 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
In-Reply-To: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1611092227200.3501@nanos>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

On Wed, 9 Nov 2016, Jason A. Donenfeld wrote:
> But for the remaining platforms, such as MIPS, this is still a
> problem. In an effort to work around this in my code, rather than
> having to invoke kmalloc for what should be stack-based variables, I
> was thinking I'd just disable preemption for those functions that use
> a lot of stack, so that stack-hungry softirq handlers don't crush it.
> This is generally unsatisfactory, so I don't want to do this
> unconditionally. Instead, I'd like to do some cludge such as:
> 
>     #ifndef CONFIG_HAVE_SEPARATE_IRQ_STACK
>     preempt_disable();

That preempt_disable() prevents merily preemption as the name says, but it
wont prevent softirq handlers from running on return from interrupt. So
what's the point?

> However, for this to work, I actual need that config variable. Would
> you accept a patch that adds this config variable to the relavent
> platforms?

It might have been a good idea, to cc all relevant arch maintainers on
that ...

> If not, do you have a better solution for me (which doesn't
> involve using kmalloc or choosing a different crypto primitive)?

What's wrong with using kmalloc?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
