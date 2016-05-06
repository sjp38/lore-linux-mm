Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF0F16B0271
	for <linux-mm@kvack.org>; Fri,  6 May 2016 18:48:17 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so175993029pab.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 15:48:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f22si20211049pfj.46.2016.05.06.15.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 15:48:16 -0700 (PDT)
Date: Fri, 6 May 2016 15:48:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] kasan/tests: add tests for user memory access
 functions
Message-Id: <20160506154815.1a2fcfa25112e48f9bb7c321@linux-foundation.org>
In-Reply-To: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com>
References: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On Fri, 6 May 2016 15:45:19 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> This patch adds some tests for user memory access API.
> KASAN doesn't pass these tests yet, but follow on patches will fix that.

I'll move this patch from [1/4] to [4/4] to avoid the minor bisection
hole.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
