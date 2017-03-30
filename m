Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB486B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 18:30:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 81so60553506pgh.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 15:30:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a26si3109570pgd.131.2017.03.30.15.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 15:30:19 -0700 (PDT)
Date: Thu, 30 Mar 2017 15:30:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] x86, kasan: add KASAN checks to atomic operations
Message-Id: <20170330153018.d59cab6e3819a6dcf86bc609@linux-foundation.org>
In-Reply-To: <cover.1489519233.git.dvyukov@google.com>
References: <cover.1489519233.git.dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: mark.rutland@arm.com, peterz@infradead.org, aryabinin@virtuozzo.com, mingo@redhat.com, will.deacon@arm.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, 14 Mar 2017 20:24:11 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:

> KASAN uses compiler instrumentation to intercept all memory accesses.
> But it does not see memory accesses done in assembly code.
> One notable user of assembly code is atomic operations. Frequently,
> for example, an atomic reference decrement is the last access to an
> object and a good candidate for a racy use-after-free.

I'm getting a pile of build errors from this patchset (and related
patches).  Due to messed up merge fixing, probably.  Please the review
process has been a bit bumpy.

So I'll drop

kasan-allow-kasan_check_read-write-to-accept-pointers-to-volatiles.patch
asm-generic-x86-wrap-atomic-operations.patch
asm-generic-x86-wrap-atomic-operations-fix.patch
asm-generic-add-kasan-instrumentation-to-atomic-operations.patch
asm-generic-fix-compilation-failure-in-cmpxchg_double.patch
x86-remove-unused-atomic_inc_short.patch
x86-asm-generic-add-kasan-instrumentation-to-bitops.patch

for now.  Please resend (against -mm or linux-next) when the dust has
settled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
