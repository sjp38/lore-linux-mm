Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C573A6B0314
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:53:04 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k68so45289542pgc.13
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:53:04 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40116.outbound.protection.outlook.com. [40.107.4.116])
        by mx.google.com with ESMTPS id h66si2344343pfe.357.2017.06.16.08.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 08:53:04 -0700 (PDT)
Subject: Re: [PATCH v3 5/7] kasan: allow kasan_check_read/write() to accept
 pointers to volatiles
References: <cover.1496743523.git.dvyukov@google.com>
 <dc2c1e0bed73a249f809793f42b82a5191d044a6.1496743523.git.dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b55a33dd-a1e5-b79f-cfe6-da1258dea2c0@virtuozzo.com>
Date: Fri, 16 Jun 2017 18:54:49 +0300
MIME-Version: 1.0
In-Reply-To: <dc2c1e0bed73a249f809793f42b82a5191d044a6.1496743523.git.dvyukov@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, kasan-dev@googlegroups.com



On 06/06/2017 01:11 PM, Dmitry Vyukov wrote:
> Currently kasan_check_read/write() accept 'const void*', make them
> accept 'const volatile void*'. This is required for instrumentation
> of atomic operations and there is just no reason to not allow that.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: x86@kernel.org
> Cc: linux-mm@kvack.org
> Cc: kasan-dev@googlegroups.com

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
