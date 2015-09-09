Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BDD786B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 06:01:47 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so6048364pac.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 03:01:47 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id u13si10584138pbs.130.2015.09.09.03.01.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 03:01:46 -0700 (PDT)
Subject: Re: [PATCH V2] kasan: fix last shadow judgement in
 memory_is_poisoned_16()
References: <55EED09E.3010107@huawei.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <55F0037E.40308@virtuozzo.com>
Date: Wed, 9 Sep 2015 13:01:34 +0300
MIME-Version: 1.0
In-Reply-To: <55EED09E.3010107@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, zhongjiang@huawei.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, ryabinin.a.a@gmail.com

On 09/08/2015 03:12 PM, Xishi Qiu wrote:
> The shadow which correspond 16 bytes memory may span 2 or 3 bytes. If the
> memory is aligned on 8, then the shadow takes only 2 bytes. So we check
> "shadow_first_bytes" is enough, and need not to call "memory_is_poisoned_1(addr + 15);".
> But the code "if (likely(!last_byte))" is wrong judgement.
> 
> e.g. addr=0, so last_byte = 15 & KASAN_SHADOW_MASK = 7, then the code will
> continue to call "memory_is_poisoned_1(addr + 15);"
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
