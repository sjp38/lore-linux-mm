Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E23F46B02FD
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:41:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b9so40475786pfl.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:41:01 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0100.outbound.protection.outlook.com. [104.47.1.100])
        by mx.google.com with ESMTPS id k6si2277236pln.397.2017.06.16.08.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 08:41:01 -0700 (PDT)
Subject: Re: [PATCH v3 3/7] asm-generic: add atomic-instrumented.h
References: <cover.1496743523.git.dvyukov@google.com>
 <09e703138fc80340ce469e3d34e42b3cb2306999.1496743523.git.dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <3f8843fe-27a1-97cf-2664-ef0d37ad481f@virtuozzo.com>
Date: Fri, 16 Jun 2017 18:43:03 +0300
MIME-Version: 1.0
In-Reply-To: <09e703138fc80340ce469e3d34e42b3cb2306999.1496743523.git.dvyukov@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
> The new header allows to wrap per-arch atomic operations
> and add common functionality to all of them.
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
> ---

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
