Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6686B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 07:01:29 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id f11so184626765igo.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 04:01:29 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0137.outbound.protection.outlook.com. [157.56.112.137])
        by mx.google.com with ESMTPS id 95si13235897otb.179.2016.05.27.04.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 04:01:28 -0700 (PDT)
Subject: Re: [PATCH] arm64: kasan: instrument user memory access API
References: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57482930.6020608@virtuozzo.com>
Date: Fri, 27 May 2016 14:02:08 +0300
MIME-Version: 1.0
In-Reply-To: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>, will.deacon@arm.com, catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org



On 05/26/2016 09:43 PM, Yang Shi wrote:
> The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
> ("x86/kasan: instrument user memory access API") added KASAN instrument to
> x86 user memory access API, so added such instrument to ARM64 too.
> 
> Tested by test_kasan module.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>  arch/arm64/include/asm/uaccess.h | 18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)

Please, cover __copy_from_user() and __copy_to_user() too.
Unlike x86, your patch doesn't instrument these two.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
