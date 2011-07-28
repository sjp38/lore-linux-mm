Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DAE666B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:55:35 -0400 (EDT)
Received: by vxg38 with SMTP id 38so2620570vxg.14
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 03:55:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311850599.2617.107.camel@laptop>
References: <20110716211850.GA23917@breakpoint.cc>
	<alpine.LFD.2.02.1107172333340.2702@ionos>
	<alpine.DEB.2.00.1107201619540.3528@tiger>
	<1311168638.5345.80.camel@twins>
	<alpine.DEB.2.00.1107201642500.4921@tiger>
	<1311176680.29152.20.camel@twins>
	<alpine.DEB.2.00.1107281346060.2841@tiger>
	<1311850599.2617.107.camel@laptop>
Date: Thu, 28 Jul 2011 13:55:33 +0300
Message-ID: <CAOJsxLFjTF0hXNx82ea5yqfqL4ZWvNoRZcju74u+A513JXdcpA@mail.gmail.com>
Subject: Re: possible recursive locking detected cache_alloc_refill() + cache_flusharray()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, Jul 28, 2011 at 1:56 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > Completely untested, hasn't even seen a compiler etc..
>>
>> Ping? Did someone send me a patch I can apply?
>
> I've queued a slightly updated patch for the lockdep tree. It should
> hopefully hit -tip soonish.

Oh, okay. Thanks, Peter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
