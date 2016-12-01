Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97AEE6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 06:35:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so89978143pgc.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 03:35:46 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00095.outbound.protection.outlook.com. [40.107.0.95])
        by mx.google.com with ESMTPS id h63si68821404pge.110.2016.12.01.03.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 03:35:45 -0800 (PST)
Subject: Re: [PATCHv4 08/10] mm/kasan: Switch to using __pa_symbol and
 lm_alias
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-9-git-send-email-labbott@redhat.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <2f3ac043-c4cc-5c5a-8ac7-1396b6bb193f@virtuozzo.com>
Date: Thu, 1 Dec 2016 14:36:05 +0300
MIME-Version: 1.0
In-Reply-To: <1480445729-27130-9-git-send-email-labbott@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On 11/29/2016 09:55 PM, Laura Abbott wrote:
> __pa_symbol is the correct API to find the physical address of symbols.
> Switch to it to allow for debugging APIs to work correctly.

But __pa() is correct for symbols. I see how __pa_symbol() might be a little
faster than __pa(), but there is nothing wrong in using __pa() on symbols.

> Other
> functions such as p*d_populate may call __pa internally. Ensure that the
> address passed is in the linear region by calling lm_alias.

Why it should be linear mapping address? __pa() translates kernel image address just fine.
This lm_alias() only obfuscates source code. Generated code is probably worse too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
