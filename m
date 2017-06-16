Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEB886B02FA
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:39:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s12so45328358pgc.2
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:39:35 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0119.outbound.protection.outlook.com. [104.47.1.119])
        by mx.google.com with ESMTPS id d6si2110107pln.412.2017.06.16.08.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 08:39:35 -0700 (PDT)
Subject: Re: [PATCH v3 2/7] x86: use s64* for old arg of
 atomic64_try_cmpxchg()
References: <cover.1496743523.git.dvyukov@google.com>
 <626e9ec17fd70591a6560e75df80dc372dc4f486.1496743523.git.dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4201c3bf-1e00-e98d-e5ae-4de2976b4a1d@virtuozzo.com>
Date: Fri, 16 Jun 2017 18:41:35 +0300
MIME-Version: 1.0
In-Reply-To: <626e9ec17fd70591a6560e75df80dc372dc4f486.1496743523.git.dvyukov@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
> atomic64_try_cmpxchg() declares old argument as long*,
> this makes it impossible to use it in portable code.
> If caller passes long*, it becomes 32-bits on 32-bit arches.
> If caller passes s64*, it does not compile on x86_64.
> 
> Change type of old arg to s64*.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
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
