Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 751B06B03B8
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:54:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 77so10908817wrb.11
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:06 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id 65si4470256wrc.166.2017.06.23.01.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:54:05 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id k67so10844576wrc.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:05 -0700 (PDT)
Date: Fri, 23 Jun 2017 10:54:02 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v5 1/4] x86: switch atomic.h to use atomic-instrumented.h
Message-ID: <20170623085402.kfzu6sri6bwi2ppo@gmail.com>
References: <cover.1498140468.git.dvyukov@google.com>
 <ff85407a7476ac41bfbdd46a35a93b8f57fa4b1e.1498140838.git.dvyukov@google.com>
 <20170622141411.6af8091132e4416e3635b62e@linux-foundation.org>
 <CACT4Y+YQchHWK+8jEo03dK21xM77pn0YePkjUTVny0-Cx8yYeg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YQchHWK+8jEo03dK21xM77pn0YePkjUTVny0-Cx8yYeg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


* Dmitry Vyukov <dvyukov@google.com> wrote:

> On Thu, Jun 22, 2017 at 11:14 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Thu, 22 Jun 2017 16:14:16 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> >> Add arch_ prefix to all atomic operations and include
> >> <asm-generic/atomic-instrumented.h>. This will allow
> >> to add KASAN instrumentation to all atomic ops.
> >
> > This gets a large number of (simple) rejects when applied to
> > linux-next.  Can you please redo against -next?
> 
> 
> This is based on tip/locking tree. Ingo already took a part of these
> series. The plan is that he takes the rest, and this applies on
> tip/locking without conflicts.

Yeah, so I've taken the rest as well, it all looks very clean now. Should show up 
in the next -next, if it passes my (arguably limited) testing.

Andrew, is this workflow fine with you? You usually take KASAN patches, but I was 
unhappy with the atomics instrumention of the earlier patches, and ended up 
reviewing the followup variants, and felt that if I hinder a patchset I might as 
well test and apply it once I'm happy with them! ;-)

Should be a special exception for this series only.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
