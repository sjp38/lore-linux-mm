Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 406686B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 04:26:02 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id g6so274502026obn.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:26:02 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0139.outbound.protection.outlook.com. [157.55.234.139])
        by mx.google.com with ESMTPS id 53si4544877otf.86.2016.05.30.01.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 May 2016 01:26:01 -0700 (PDT)
Subject: Re: [v2 PATCH] arm64: kasan: instrument user memory access API
References: <1464382863-11879-1-git-send-email-yang.shi@linaro.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <574BF941.7090906@virtuozzo.com>
Date: Mon, 30 May 2016 11:26:41 +0300
MIME-Version: 1.0
In-Reply-To: <1464382863-11879-1-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>, will.deacon@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org


On 05/28/2016 12:01 AM, Yang Shi wrote:
> The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
> ("x86/kasan: instrument user memory access API") added KASAN instrument to
> x86 user memory access API, so added such instrument to ARM64 too.
> 
> Define __copy_to/from_user in C in order to add kasan_check_read/write call,
> rename assembly implementation to __arch_copy_to/from_user.
> 
> Tested by test_kasan module.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> 

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
