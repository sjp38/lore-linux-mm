Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2873783293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:06:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k71so45182740pgd.6
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 09:06:38 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0128.outbound.protection.outlook.com. [104.47.0.128])
        by mx.google.com with ESMTPS id z3si2196476plb.1.2017.06.16.09.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 09:06:37 -0700 (PDT)
Subject: Re: [PATCH v3 6/7] asm-generic: add KASAN instrumentation to atomic
 operations
References: <cover.1496743523.git.dvyukov@google.com>
 <116e9ee125e74b1fbb35244c845cec1a5ec89355.1496743523.git.dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <52c19a08-0aaa-8ed3-1bca-782bf9cfbe90@virtuozzo.com>
Date: Fri, 16 Jun 2017 19:08:36 +0300
MIME-Version: 1.0
In-Reply-To: <116e9ee125e74b1fbb35244c845cec1a5ec89355.1496743523.git.dvyukov@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org



On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
> KASAN uses compiler instrumentation to intercept all memory accesses.
> But it does not see memory accesses done in assembly code.
> One notable user of assembly code is atomic operations. Frequently,
> for example, an atomic reference decrement is the last access to an
> object and a good candidate for a racy use-after-free.
> 
> Add manual KASAN checks to atomic operations.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>,
> Cc: Andrew Morton <akpm@linux-foundation.org>,
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
> Cc: Ingo Molnar <mingo@redhat.com>,
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: x86@kernel.org
> ---

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
