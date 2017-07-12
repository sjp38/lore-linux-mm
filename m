Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C52156B056F
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 22:01:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d18so9873500pfe.8
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 19:01:41 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m184si769215pgm.585.2017.07.11.19.01.37
        for <linux-mm@kvack.org>;
        Tue, 11 Jul 2017 19:01:40 -0700 (PDT)
Date: Wed, 12 Jul 2017 11:00:53 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170712020053.GB20323@X58A-UD3R>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711161232.GB28975@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Jul 11, 2017 at 06:12:32PM +0200, Peter Zijlstra wrote:
> 
> ARGH!!! please, if there are known holes in patches, put a comment in.

The fourth of the last change log is the comment, but it was not enough.
I will try to add more comment in that case.

> I now had to independently discover this problem during review of the
> last patch.
> 

...

> 
> Right, like I wrote in the comment; I don't think you need quite this
> much.
> 
> The problem only happens if you rewind more than MAX_XHLOCKS_NR;
> although I realize it can be an accumulative rewind, which makes it
> slightly more tricky.
> 
> We can either make the rewind more expensive and make xhlock_valid()
> false for each rewound entry; or we can keep the max_idx and account

Does max_idx mean the 'original position - 1'?

> from there. If we rewind >= MAX_XHLOCKS_NR from the max_idx we need to
> invalidate the entire state, which we can do by invaliding

Could you explain what the entire state is?

> xhlock_valid() or by re-introduction of the hist_gen_id. When we

What does the re-introduction of the hist_gen_id mean?

> invalidate the entire state, we can also clear the max_idx.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
