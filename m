Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 168DE6B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 09:27:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 197so3529534pfv.13
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 06:27:40 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 90si7465842plc.317.2017.03.29.06.27.39
        for <linux-mm@kvack.org>;
        Wed, 29 Mar 2017 06:27:39 -0700 (PDT)
Date: Wed, 29 Mar 2017 14:27:18 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 4/8] asm-generic: add atomic-instrumented.h
Message-ID: <20170329132718.GI23442@leverpostej>
References: <cover.1490717337.git.dvyukov@google.com>
 <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
 <20170328213513.GB12803@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328213513.GB12803@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Tue, Mar 28, 2017 at 02:35:13PM -0700, Matthew Wilcox wrote:
> On Tue, Mar 28, 2017 at 06:15:41PM +0200, Dmitry Vyukov wrote:
> > The new header allows to wrap per-arch atomic operations
> > and add common functionality to all of them.
> 
> Why a new header instead of putting this in linux/atomic.h?

The idea was that doing it this way allowed architectures to switch over
to the arch_* naming without a flag day. Currently this only matters for
KASAN, which is only supported by a couple of architectures (arm64,
x86).

I seem to recall that there was an issue that prevented us from solving
this with ifdeffery early in linux/atomic.h like:

#ifdef arch_op
#define op(...) ({ 		\
	kasna_whatever(...)	\
	arch_op(...)		\
})
#endif

... but I can't recall specifically what it was.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
