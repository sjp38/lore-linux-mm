Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 41B786B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 06:58:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c5so10418929wmi.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:58:39 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id s80si1473332wma.18.2017.03.24.03.57.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 03:57:03 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id u1so1543976wra.3
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:57:03 -0700 (PDT)
Date: Fri, 24 Mar 2017 11:57:00 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170324105700.GB20282@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com>
 <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Dmitry Vyukov <dvyukov@google.com> wrote:

> > Are just utterly disgusting that turn perfectly readable code into an 
> > unreadable, unmaintainable mess.
> >
> > You need to find some better, cleaner solution please, or convince me that no 
> > such solution is possible. NAK for the time being.
> 
> Well, I can just write all functions as is. Does it better confirm to kernel 
> style?

I think writing the prototypes out as-is, properly organized, beats any of these 
macro based solutions.

> [...] I've just looked at the x86 atomic.h and it uses macros for similar 
> purpose (ATOMIC_OP/ATOMIC_FETCH_OP), so I thought that must be idiomatic kernel 
> style...

Mind fixing those too while at it?

And please squash any bug fixes and re-send a clean series against latest upstream 
or so.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
