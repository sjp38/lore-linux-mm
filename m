Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 292826B0023
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 07:16:40 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id y8so9602029ote.15
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 04:16:40 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g197si270557oic.110.2018.03.05.04.16.38
        for <linux-mm@kvack.org>;
        Mon, 05 Mar 2018 04:16:39 -0800 (PST)
Date: Mon, 5 Mar 2018 12:16:41 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] kasan, arm64: clean up KASAN_SHADOW_SCALE_SHIFT usage
Message-ID: <20180305121641.GD8571@arm.com>
References: <44281e784702443f06edb837ec672984783a9621.1519923749.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44281e784702443f06edb837ec672984783a9621.1519923749.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Kostya Serebryany <kcc@google.com>

On Thu, Mar 01, 2018 at 06:07:12PM +0100, Andrey Konovalov wrote:
> This is a follow up patch to the series I sent recently that cleans up
> KASAN_SHADOW_SCALE_SHIFT usage (which value was hardcoded and scattered
> all over the code). This fixes the one place that I forgot to fix.
> 
> The change is purely aesthetical, instead of hardcoding the value for
> KASAN_SHADOW_SCALE_SHIFT in arch/arm64/Makefile, an appropriate variable
> is declared and used.

Cheers, I'll pick this up.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
