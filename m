Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6376B0069
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 11:33:07 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a10so540506pgq.3
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 08:33:07 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0134.outbound.protection.outlook.com. [104.47.2.134])
        by mx.google.com with ESMTPS id s187si289457pgc.532.2017.12.05.08.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 08:33:05 -0800 (PST)
Subject: Re: [PATCH v4 3/5] kasan: support alloca() poisoning
References: <20171204191735.132544-1-paullawrence@google.com>
 <20171204191735.132544-4-paullawrence@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <92997308-7c91-7d37-f699-1a9ea9be14ed@virtuozzo.com>
Date: Tue, 5 Dec 2017 19:36:34 +0300
MIME-Version: 1.0
In-Reply-To: <20171204191735.132544-4-paullawrence@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On 12/04/2017 10:17 PM, Paul Lawrence wrote:
> clang's AddressSanitizer implementation adds redzones on either side of
> alloca()ed buffers.  These redzones are 32-byte aligned and at least 32
> bytes long.
> 
> __asan_alloca_poison() is passed the size and address of the allocated
> buffer, *excluding* the redzones on either side.  The left redzone will
> always be to the immediate left of this buffer; but AddressSanitizer may
> need to add padding between the end of the buffer and the right redzone.
> If there are any 8-byte chunks inside this padding, we should poison
> those too.
> 
> __asan_allocas_unpoison() is just passed the top and bottom of the
> dynamic stack area, so unpoisoning is simpler.
> 
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
