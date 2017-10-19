Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2776B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:41:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t69so3211859wmt.7
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:41:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g131sor274848wma.54.2017.10.19.02.41.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 02:41:50 -0700 (PDT)
Date: Thu, 19 Oct 2017 11:41:47 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171019094147.n43gdh5fbp4rsjzc@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <20171018100944.g2mc6yorhtm5piom@gmail.com>
 <20171019043240.GA3310@X58A-UD3R>
 <20171019055730.mlpoz333ekflacs2@gmail.com>
 <20171019061112.GB3310@X58A-UD3R>
 <20171019062255.GC3310@X58A-UD3R>
 <20171019081053.2mmzzjgfwgtv5lz3@gmail.com>
 <F6531D8286A0B34FBC858F176F707962027B9228C9@LGEVEXMBHQSVC1.LGE.NET>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <F6531D8286A0B34FBC858F176F707962027B9228C9@LGEVEXMBHQSVC1.LGE.NET>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?77+92rrvv73Dti/vv73vv73vv73Tv++/ve+/ve+/ve+/ve+/vS9TVyBQbGF0?= =?utf-8?B?Zm9ybSjvv73vv70pQU9U77+977+9KGJ5dW5nY2h1bC5wYXJrQGxnZS5jb20p?= <byungchul.park@lge.com>
Cc: "peterz@infradead.org" <peterz@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>


* i? 1/2 Uoi? 1/2 A?/i? 1/2 i? 1/2 i? 1/2 O?i? 1/2 i? 1/2 i? 1/2 i? 1/2 i? 1/2 /SW Platform(i? 1/2 i? 1/2 )AOTi? 1/2 i? 1/2 (byungchul.park@lge.com) <byungchul.park@lge.com> wrote:

> I don't want to pretend I'm perfect. Of course, I can make mistakes.
> I'm just saying that *I have not seen* any crash by cross-release.
> 
> In that case you pointed out, likewise, the crash was caused by ae813308f:
> lockdep: Avoid creating redundant links, which is not related to the feature
> actually. It was also falsely accused at the time again...
> 
> Of course, it's my fault not to have made the design more robust so that
> others can modify lockdep code caring less after cross-release commit.
> That's what I'm sorry for.
> 
> I already mentioned the above in the thread talking about the issue you
> are pointing now. Of course, I basically appreciate all comments and
> suggestions you have given, but you seem to have mis-understood some
> issues wrt cross-release feature.

Two different cross-release commits got bisected to with kernel crashes:

  Sep 30 kernel test rob    | ce07a9415f ("locking/lockdep: Make check_prev_add() able to .."):  BUG: unable to handle kernel NULL pointer dereference at 00000020
  Oct 03 Fengguang Wu       | [lockdep] b09be676e0 BUG: unable to handle kernel NULL pointer dereference at 000001f2

The first crash was bisected to:

  ce07a9415f26: locking/lockdep: Make check_prev_add() able to handle external stack_trace

The second crash was bisected to:

  b09be676e0ff: locking/lockdep: Implement the 'crossrelease' feature

... and unless your argument that both bisections were bad, it doesn't matter 
where the root cause ended up being, fact is that it was not a problem free series 
and let's not pretend it was.

Note that to me it *really* does not matter that a commit causes a crash: bugs 
happen, they are part of software development done by humans - so as long as it's 
not a pattern of underlying carelessness or some development process error it's 
not something to get emotional about.

Ok?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
