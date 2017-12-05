Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB8BE6B0038
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 11:34:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q186so512725pga.23
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 08:34:04 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0094.outbound.protection.outlook.com. [104.47.0.94])
        by mx.google.com with ESMTPS id a5si283265pgn.670.2017.12.05.08.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 08:34:03 -0800 (PST)
Subject: Re: [PATCH v4 5/5] kasan: added functions for unpoisoning stack
 variables
References: <20171204191735.132544-1-paullawrence@google.com>
 <20171204191735.132544-6-paullawrence@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f324833c-bf22-2548-98e3-764fbd2d49b0@virtuozzo.com>
Date: Tue, 5 Dec 2017 19:37:31 +0300
MIME-Version: 1.0
In-Reply-To: <20171204191735.132544-6-paullawrence@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>



On 12/04/2017 10:17 PM, Paul Lawrence wrote:
> From: Alexander Potapenko <glider@google.com>
> 
> As a code-size optimization, LLVM builds since r279383 may
> bulk-manipulate the shadow region when (un)poisoning large memory
> blocks.  This requires new callbacks that simply do an uninstrumented
> memset().
> 
> This fixes linking the Clang-built kernel when using KASAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> [ghackmann@google.com: fix memset() parameters, and tweak
>  commit message to describe new callbacks]
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
