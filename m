Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5BB6B02FD
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:52:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p14so45484462pgc.9
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:52:24 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40139.outbound.protection.outlook.com. [40.107.4.139])
        by mx.google.com with ESMTPS id t2si2228620pgr.502.2017.06.16.08.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 08:52:22 -0700 (PDT)
Subject: Re: [PATCH v3 4/7] x86: switch atomic.h to use atomic-instrumented.h
References: <cover.1496743523.git.dvyukov@google.com>
 <ca52d3d26fcc5d5d8af430bc269610d3aa7df252.1496743523.git.dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <7c4a35fe-67eb-6520-b036-bfa2b4267276@virtuozzo.com>
Date: Fri, 16 Jun 2017 18:54:03 +0300
MIME-Version: 1.0
In-Reply-To: <ca52d3d26fcc5d5d8af430bc269610d3aa7df252.1496743523.git.dvyukov@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
> Add arch_ prefix to all atomic operations and include
> <asm-generic/atomic-instrumented.h>. This will allow
> to add KASAN instrumentation to all atomic ops.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: x86@kernel.org
> 
> ---




> -static __always_inline void atomic_set(atomic_t *v, int i)
> +static __always_inline void arch_atomic_set(atomic_t *v, int i)
>  {
> +	/*
> +	 * We could use WRITE_ONCE_NOCHECK() if it exists, similar to
> +	 * READ_ONCE_NOCHECK() in arch_atomic_read(). But there is no such
> +	 * thing at the moment, and introducing it for this case does not
> +	 * worth it.
> +	 */


I'd rather remove this comment. I woudn't say that WRITE_ONCE() here looks confusing
and needs comment. Also there is no READ_ONCE_NOCHECK() in arch_atomic_read() anymore.

Otherwise,
	Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

>  	WRITE_ONCE(v->counter, i);
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
