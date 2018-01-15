Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7D136B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 11:35:05 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x24so7953638pge.13
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 08:35:05 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00115.outbound.protection.outlook.com. [40.107.0.115])
        by mx.google.com with ESMTPS id y6si22057pgr.220.2018.01.15.08.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 08:35:04 -0800 (PST)
Subject: Re: [PATCH v2 2/2] kasan: clean up KASAN_SHADOW_SCALE_SHIFT usage
References: <cover.1515775666.git.andreyknvl@google.com>
 <34937ca3b90736eaad91b568edf5684091f662e3.1515775666.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b3d59ebe-9bdd-46a2-377d-8f242ccef426@virtuozzo.com>
Date: Mon, 15 Jan 2018 19:35:11 +0300
MIME-Version: 1.0
In-Reply-To: <34937ca3b90736eaad91b568edf5684091f662e3.1515775666.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Andrew Morton <akpm@linux-foundation.org>



On 01/12/2018 07:49 PM, Andrey Konovalov wrote:
> Right now the fact that KASAN uses a single shadow byte for 8 bytes of
> memory is scattered all over the code.
> 
> This change defines KASAN_SHADOW_SCALE_SHIFT early in asm include files
> and makes use of this constant where necessary.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
