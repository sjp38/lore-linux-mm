Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35B09828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:38:08 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id he1so31590446pac.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:38:08 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o124si40602224pfb.247.2016.06.21.07.38.07
        for <linux-mm@kvack.org>;
        Tue, 21 Jun 2016 07:38:07 -0700 (PDT)
Date: Tue, 21 Jun 2016 15:38:03 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [v3 PATCH] arm64: kasan: instrument user memory access API
Message-ID: <20160621143802.GB14542@e104818-lin.cambridge.arm.com>
References: <1465422056-20531-1-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465422056-20531-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: aryabinin@virtuozzo.com, will.deacon@arm.com, mark.rutland@arm.com, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Wed, Jun 08, 2016 at 02:40:56PM -0700, Yang Shi wrote:
> The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
> ("x86/kasan: instrument user memory access API") added KASAN instrument to
> x86 user memory access API, so added such instrument to ARM64 too.
> 
> Define __copy_to/from_user in C in order to add kasan_check_read/write call,
> rename assembly implementation to __arch_copy_to/from_user.
> 
> Tested by test_kasan module.
> 
> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reviewed-by: Mark Rutland <mark.rutland@arm.com>
> Tested-by: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Queued for 4.8. Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
